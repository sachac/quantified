class TimeTrackerLog
  attr_accessor :calendar, :account

  def initialize(account)
    self.account = account
  end

  def login(username, password)
    @client = GData::Client::Calendar.new
    @client.clientlogin(username, password)
    # Retrieve the list of calendars
    list = @client.get("https://www.google.com/calendar/feeds/default/owncalendars/full")
    # Find the calendar
    @calendar = nil
    list.to_xml.elements.each('entry/title') do |e|
      if (e.text == 'Time tracking') then 
        @calendar = e.parent.elements["content"].attributes["src"] 
      end
    end
  end

  def clear(start_time, end_time)
    # Get rid of all records between start time and end time; This is
    # a little coarse, but I'll rely on the fact that I've trimmed the
    # records to start and end on midnight boundaries
    Record.destroy_all(["start_time >= ? AND end_time <= ?", start_time, end_time])
  end
end
