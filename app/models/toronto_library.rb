class TorontoLibrary < ActiveRecord::Base
  belongs_to :user
  attr_accessor :agent
#  attr_accessible :card, :pin, :name
  def login
    @agent ||= Mechanize.new
    self.logout
    page = @agent.get 'https://www.torontopubliclibrary.ca/youraccount'
    form = page.form_with :name => 'form_signin'
    if form
      form.userId = self.read_attribute('card')
      form.password = self.read_attribute('pin')
      form.submit
    end
    self
  end

  def renew_items(library_items)
    self.login if @agent.nil? or @agent.page.nil?
    form = @agent.page.form_with :id => 'renewitems'
    ids = library_items.map(&:library_id).compact
    items_checked = Array.new
    @agent.page.parser.css('#renewcharge').css('input').each do |x|
      if x.attributes['name'] && x.attributes['name'].value != 'id' then
        info = x.attributes['name'].value.split('^')
        if ids.include?(info[1])
          checkbox = form.checkbox_with(:name => x.attributes['name'].to_s)
          if checkbox
            checkbox.check
            items_checked << x.attributes['name']
          else
          end
        end
      end
    end
    if items_checked.size > 0
      form.submit if form
    end    
  end

  def renew_items_by_date(date)
    items_checked = Array.new
    form = @agent.page.form_with :id => 'renewitems'
    @agent.page.parser.css('#renewcharge').css('input').each do |x|
      if x.attributes['name'] && x.attributes['name'].value != 'id' then
        info = x.attributes['name'].value.split('^')
        due_string = x.parent.parent.inner_html
        match_data = due_string.match(/<!-- Print the date due -->[\r\n\t]*([^\r\n\t<\/]+)\/([^\r\n\t<\/]+)\/([^\r\n\t<\/,]+)/)
        due = Time.zone.local(match_data[3].to_i, match_data[2].to_i, match_data[1].to_i)
        if (due <= date)
          checkbox = form.checkbox_with(:name => x.attributes['name'].to_s)
	  if checkbox
	    checkbox.check
            items_checked << row
	  end  
        end
      end
    end
    if items_checked.size > 0
      form.submit if form
    end
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
         :details => x.attributes['name'],
         :toronto_library_id => self.id,
         :status => !status || status[1].blank? || (status[1] == 'overdue') ? 'due' : status[1].strip.downcase,
         :due => Time.zone.local(match_data[3].to_i, match_data[2].to_i, match_data[1].to_i)}
      end
    end
  end

  REQUEST_ITEM_BASE_URL = 'https://www.torontopubliclibrary.ca/placehold?itemId=';
  def request_item(item_id)
    page = @agent.get(REQUEST_ITEM_BASE_URL + URI.escape(item_id))
    form = page.form :name => 'form_place-hold'
    if form
      result = form.submit
      if result.content =~ /The hold was successfully placed/
        return :success
      else
        return false
      end
    else
      return nil
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
    stamp = Time.now
    self.login 
    self.count_pickups!
    items = list_items
    items.each do |item|
      # Does the item exist?
      rec = LibraryItem.where("library_id = ?", item[:library_id]).first
      if rec then
        rec.status = 'due' if rec.status != 'lost'
        rec.due = item[:due]
        rec.updated_at = stamp
      else
        rec = LibraryItem.create(item.merge(:user => self.user))
        rec.checkout_date ||= Time.zone.today
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
