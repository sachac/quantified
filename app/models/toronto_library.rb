class TorontoLibrary < ActiveRecord::Base
  belongs_to :user
  attr_accessor :agent
#  attr_accessible :card, :pin, :name
  def login
    @agent ||= Mechanize.new
    self.logout
    page = @agent.get 'http://beta.torontopubliclibrary.ca/youraccount'
    form = page.form_with :name => 'form_signin'
    if form
      form.userId = self.read_attribute('card')
      form.password = self.read_attribute('pin')
      form.submit
    end
    self
  end

  def list_items
    @agent.page.parser.css('#renewcharge').css('input').map do |x|
      if x.attributes['name'] && x.attributes['name'].value != 'id' then
        info = x.attributes['name'].value.split('^')
        due_string = x.parent.parent.inner_html
        match_data = due_string.match(/<!-- Print the date due -->[\r\n\t]*([^\r\n\t<\/]+)\/([^\r\n\t<\/]+)\/([^\r\n\t<\/,]+)/)
        status = due_string.match(/<!-- Status -->[ \r\n\t]*([^\r\n\t<]+)/)
        {:library_id => info[1], 
         :dewey => info[2], 
         :author => info[4], 
         :title => info[5], 
         :toronto_library_id => self.id,
         :status => !status || status[1].blank? ? 'due' : status[1].strip.downcase,
         :due => Date.new(match_data[3].to_i, match_data[2].to_i, match_data[1].to_i)}
      end
    end
  end

  def count_pickups!
    self.pickup_count = @agent.page.parser.css('#avail_list').css('input').count { |x| x.attributes['name'] && x.attributes['name'].value != 'id' }
    self 
  end

  def logout
    if @agent and @agent.page and @agent.page.link_with(:text => 'Sign Out') then
      @agent.page.link_with(:text => 'Sign Out').click
    end
  end

  def refresh_items
    # Replace this with selective updating
    stamp = Time.now
    self.login
    self.count_pickups!
    items = list_items
    items.each do |item|
      # Does the item exist?
      item.user = self.user
      rec = LibraryItem.where("library_id = ?", item[:library_id]).first
      if rec then
        rec.due = item[:due]
        rec.updated_at = stamp
      else
        rec = LibraryItem.create(item)
        rec.checkout_date ||= Date.today
      end
      rec.status ||= item[:status]
      rec.save
    end
    # Mark all the un-updated due books as returned
    LibraryItem.find(:all, :conditions => ["toronto_library_id = ? AND updated_at < ? AND (status IS NULL OR status='due' OR status='read')", self.id, stamp]).each do |item|
      item.status = "returned"
      item.save
    end
    self.save
  end

  def self.pickup_count(account)
    TorontoLibrary.where('user_id=?', account.id).sum('pickup_count')
  end
end
