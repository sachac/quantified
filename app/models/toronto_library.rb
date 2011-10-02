class TorontoLibrary 
  attr_accessor :agent
  def login(c)
    @agent ||= Mechanize.new
    logout
    page = @agent.get 'http://beta.torontopubliclibrary.ca/youraccount'
    form = page.form_with :name => 'form_signin'
    form.userId = c["card"]
    form.password = c["pin"]
    form.submit
    self
  end

  def list_items
    @agent.page.parser.css("#renewcharge").css('input').map do |x|
      info = x.attributes['name'].value.split('^')
      due_string = x.parent.parent.inner_html
      match_data = due_string.match(/<!-- Print the date due -->[\r\n\t]*([^\r\n\t<\/]+)\/([^\r\n\t<\/]+)\/([^\r\n\t<\/,]+)/)

      {:library_id => info[1], :dewey => info[2], :author => info[4], :title => info[5], :due => Date.new(match_data[3].to_i, match_data[2].to_i, match_data[1].to_i)}
    end
  end

  def logout
    if @agent and @agent.page and @agent.page.link_with(:text => 'Sign Out') then
      @agent.page.link_with(:text => 'Sign Out').click
    end
  end

  def refresh_items
    # Replace this with selective updating
    stamp = Time.now
    Settings.library_cards.each do |c|
      login(c)
      items = list_items
      items.each do |item|
        # Does the item exist?
        rec = LibraryItem.where("library_id = ?", item[:library_id]).first
        if rec then
          rec.due = item[:due]
	  rec.updated_at = stamp
        else
          rec = LibraryItem.create(item)
        end
        rec.save
        status = "due"
      end
    end
    # Mark all the un-updated due books as returned
    LibraryItem.find(:all, :conditions => ["updated_at < ? AND (status IS NULL OR status='due')", stamp]).each do |item|
      item.status = "returned"
      item.save
    end
  end
end
