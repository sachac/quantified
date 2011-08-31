class TimeTrackerLog
  attr_accessor :calendar
  def initialize
  end
  def login
    @client = GData::Client::Calendar.new
    @client.clientlogin('sacha@sachachua.com', 'Sbj9ork12!!')
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
    TimeRecord.destroy_all(["start_time >= ? AND end_time <= ?", start_time, end_time])
  end

  def refresh(start_time, end_time)
    # Retrieve the entries
    start_fmt = (start_time - 1.day).xmlschema
    end_fmt = end_time.xmlschema
    # Sledgehammer approach: delete all the entries from start_time to
    # end_time, and replace them with new ones. We can replace this
    # with a more elegant synchronization someday.
    clear(start_time, end_time)
    list = @client.get(@calendar + "?orderby=starttime&start-min=#{start_fmt}&start-max=#{end_fmt}")
    while list do 
      parsed = list.to_xml.elements.each("entry") do |e| 
        text = e.elements["title"].text 
        event_start = Time.parse(e.elements["gd:when"].attributes["startTime"])
        event_end = Time.parse(e.elements["gd:when"].attributes["endTime"])
        if (event_end >= start_time) then
          # Chop off start time and end time according to time
          event_start = [event_start, start_time].max
          event_end = [event_end, end_time].min
          # If the event starts before midnight
          if (event_start < event_end.midnight) then
            rec = TimeRecord.new(:name => text, :start_time => event_start, :end_time => event_end.midnight)
            rec.save
            event_start = event_end.midnight
          end
          rec = TimeRecord.new(:name => text, :start_time => event_start, :end_time => event_end)
          rec.save
        end
      end
      next_url = list.to_xml.elements["link[@rel='next']"]
      if next_url then
        list = @client.get(next_url.attributes['href'])
      else
        list = nil
      end
    end
    entries(start_time, end_time)
  end

  def entries(start_time, end_time)
    TimeRecord.find(:all, :conditions => ["start_time >= ? AND end_time <= ?", start_time, end_time])
  end

  def summarize(start_time, end_time)
    list = entries(start_time, end_time)
    result = Hash.new
    total = 0.seconds
    list.each do |x|
      if (x.name == 'Work' || x.name == 'Sleep') then
        result['! ' + x.name] ||= 0.seconds
        result['! ' + x.name] += (x.end_time - x.start_time)
      else
        result[x.name] ||= 0.seconds
        result[x.name] += (x.end_time - x.start_time)
      end  
      if (x.name =~ /^Disc\./) then
        result['! Disc.'] ||= 0.seconds
        result['! Disc.'] += (x.end_time - x.start_time)
      elsif (x.name =~ /^Routines?/) then
        result['! Routines'] ||= 0.seconds
        result['! Routines'] += (x.end_time - x.start_time)
      end
      puts "#{x.name} - #{(x.end_time - x.start_time) / 3600.0}"
      total += (x.end_time - x.start_time)
    end
    result["! Sleep"] ||= 0.seconds
    puts end_time.to_s
    puts start_time.to_s
    puts (total / 3600.0)
    puts ((end_time - start_time - total) / 3600.00)
    puts "--"
    result["! Sleep"] += end_time - start_time - total
    result
  end

  def compare_two(first_summary, second_summary)
    # Now compare the two
    all_keys = (first_summary.keys | second_summary.keys)
    all_keys.sort!
    out = ""
    all_keys.each do |k|
      first = (first_summary[k] ? first_summary[k] : 0) / 3600.0
      second = (second_summary[k] ? second_summary[k] : 0) / 3600.0
      out << "| %s | %.1f | %.1f | %.1f |\n" % [k, first, second, (second - first)]
    end
    out
  end
  
  def compare_weeks
    first_week_start = (Date.parse("last Saturday") - 2.weeks).midnight
    second_week_start = (Date.parse("last Saturday") - 1.week).midnight
    second_week_end = Date.parse("last Saturday").midnight
    first_summary = summarize(first_week_start, second_week_start)
    second_summary = summarize(second_week_start, second_week_end)
    compare_two(first_summary, second_summary)
  end

  def create_entry(text, start_time, end_time)
    entry = "<entry xmlns='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>
  <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/g/2005#event'></category>
  <title type='text'>#{text}</title>
  <gd:transparency value='http://schemas.google.com/g/2005#event.opaque'></gd:transparency>
  <gd:eventStatus value='http://schemas.google.com/g/2005#event.confirmed'></gd:eventStatus>
  <gd:when startTime='#{start_time.xmlschema}' endTime='#{end_time.xmlschema}'></gd:when>
</entry>"
    @client.post(@calendar, entry)
  end


end
