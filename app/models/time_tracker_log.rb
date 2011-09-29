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

  def create_record(event_start, event_end, text) 
    puts "#{event_start} #{event_end} #{text}"
    # If the event starts before midnight
    if (event_start < event_end.midnight) then
      rec = TimeRecord.new(:name => text, :start_time => event_start, :end_time => event_end.midnight)
      rec.save
      event_start = event_end.midnight
    end
    rec = TimeRecord.new(:name => text, :start_time => event_start, :end_time => event_end)
    rec.save
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
        end
        create_record(event_start, event_end, text)
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

  def refresh_from_csv(filename)
    # Parse the file and determine start and end times
    Time.zone = "America/Toronto"
    if filename.is_a? String then
      file = File.new(filename, 'r')
    else
      file = filename
    end
    entries = Array.new
    min = max = nil
    file.each_line do |line|
      row = line.split(',')
      if (row[0] == 'Date') then
        next  # Skip the header row
      end
      # Parse the date
      if !row[2].blank? then
        start_time = Time.parse("#{row[0]} #{row[2]} America/Toronto", "%d.%m.%Y %H:%M %Z")
        end_time = Time.parse("#{row[0]} #{row[3]} America/Toronto", "%d.%m.%Y %H:%M %Z")
        if (start_time > end_time) then
          end_time += 1.day    # Must have checked in on the next day
        end
        cat = row[5]
        total = (end_time - start_time) / 3600.0
        entry = Hash[ :start => start_time.to_time, :end => end_time.to_time, :text => cat ]
        if min.nil? then
          min = start_time
          max = end_time
        else
          min = [start_time, min].min
          max = [end_time, max].max
        end
        entries.push entry
        # puts "#{start_time}\t#{end_time}\t#{cat}\t#{total}\t#{accuracy}"
      end
    end
    # Delete the entries from start to end
    if (!min.nil?) then
      self.clear(min.to_time, max.to_time)
      entries.each do |e|
        create_record(e[:start], e[:end], e[:text])
      end
      # TODO Update Google Calendar also
    end
  end

  def entries(start_time, end_time)
    TimeRecord.find(:all, :conditions => ["start_time >= ? AND end_time <= ?", start_time, end_time])
  end

  def by_day(entries)
    days = Hash.new
    days_total = Hash.new
    entries.each do |e|
      days[e.start_time.midnight] ||= Hash.new
      days[e.start_time.midnight][e.name] ||= 0
      days[e.start_time.midnight][e.name] += (e.end_time - e.start_time)
      unless (e.name == 'A - Sleep') then
        days_total[e.start_time.midnight] ||= 0
        days_total[e.start_time.midnight] += (e.end_time - e.start_time)
      end
    end
    # Go back and fill in sleep
    days.each do |date,list|
      days[date]['A - Sleep'] = 86400 - days_total[date]
    end
    days
  end
  def summarize(start_time, end_time)
    list = entries(start_time, end_time)
    result = Hash.new
    total = 0.seconds
    list.each do |x|
      result[x.name] ||= 0.seconds
      result[x.name] += (x.end_time - x.start_time)
      if (x.name =~ /^D -/) then
        result['! Discretionary'] ||= 0.seconds
        result['! Discretionary'] += (x.end_time - x.start_time)
      elsif (x.name =~ /^P - ?/) then
        result['! Personal care'] ||= 0.seconds
        result['! Personal care'] += (x.end_time - x.start_time)
      elsif (x.name =~ /^UW - ?/) then
        result['! Unpaid work'] ||= 0.seconds
        result['! Unpaid work'] += (x.end_time - x.start_time)
      end
      total += (x.end_time - x.start_time)
    end
    result["A - Sleep"] = [end_time, Time.now].min - start_time
    result["A - Sleep"] -= (result['! Discretionary'] || 0) + (result['! Personal care'] || 0) + (result['! Unpaid work'] || 0) + (result['A - Work'] || 0)
    puts "#{end_time.to_s} #{start_time.to_s} #{result['! Discretionary']} #{result['! Personal care']} #{result['! Unpaid work']} #{result['A - Work']}\n"
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
