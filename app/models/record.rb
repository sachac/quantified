class Record < ActiveRecord::Base
  belongs_to :record_category
  belongs_to :user
  serialize :data
  scope :activities, -> { joins(:record_category).where(:record_categories => {:category_type => 'activity'}).readonly(false) }
  scope :public_records, -> { where("records.data IS NULL OR LOWER(records.data) NOT LIKE '%!private%'") }
  before_save :add_data
  validate :end_timestamp_must_be_after_start

  def data=(val)
    if val.is_a? String
      write_attribute(:data, ActiveSupport::JSON.decode(val))
    else
      write_attribute(:data, val)
    end
  end

  def set_data(name, value)
    self.data ||= Hash.new
    self.data[name] = value
  end

  def end_timestamp
    # Only activities have end timestamps
    if self.record_category and self.activity?
      return self[:end_timestamp]
    else
      return nil
    end
  end

  def duration
    # Only activities have end timestamps
    if self.record_category and self.activity?
      return self[:duration]
    else
      return nil
    end
  end
  
  def end_timestamp_must_be_after_start
    if !end_timestamp.blank? and end_timestamp < timestamp
      errors.add(:end_timestamp, 'must be after beginning of record')
    end
  end

  # Returns records split by midnight in reverse chronological order
  def self.split(records)
    if records.is_a? Record
      start_time = records.timestamp
      if records.activity?
        end_time = records.end_timestamp || Time.zone.now
        list = Array.new
        current = records
        # While the end time crosses a midnight
        while start_time.in_time_zone.midnight != end_time.in_time_zone.midnight
          current = current.dup
          current.timestamp = start_time.in_time_zone
          current.end_timestamp = (start_time.in_time_zone + 1.day).midnight
          current.duration = current.end_timestamp - current.timestamp
          current.id = records.id
          list << current
          start_time = (start_time + 1.day).midnight
        end
        if start_time < end_time
          # At this point, start time and end time are on the same date
          current = current.dup
          current.timestamp = start_time
          current.end_timestamp = end_time
          current.duration = current.end_timestamp - current.timestamp
          current.id = records.id
          list << current
        end
        list.reverse
      else
        [records]
      end
    else
      records.map { |x| Record.split(x) }.flatten
    end
  end

  def add_data
    self.date = self.timestamp.in_time_zone.to_date
    # Set end time automatically if we are backdating activities
    if !self.end_timestamp
      # See if there are any activities after this
      next_act = self.next_activity
      if next_act
        self.end_timestamp = next_act.timestamp
      end
    end
    # Follow manual
    if self.end_timestamp and self.timestamp and (self.timestamp_changed? || self.end_timestamp_changed?)
      self.duration = self.end_timestamp - self.timestamp
    end
  end

  def update_next
    if !self.manual and self.record_category.category_type == 'activity'
      next_activity = self.next_activity
      if next_activity and self.end_timestamp and next_activity.timestamp != self.end_timestamp
        next_activity.timestamp = self.end_timestamp
        if next_activity.end_timestamp
          next_activity.duration = next_activity.end_timestamp - next_activity.timestamp
        else
          next_activity.duration = nil
        end
        next_activity.save
      end
    end
  end
  def update_previous
    previous_activity = self.previous_activity
    if self.record_category.category_type == 'activity' and previous_activity and !previous_activity.manual? and (!previous_activity.end_timestamp or previous_activity.end_timestamp != self.timestamp)
      previous_activity.end_timestamp = self.timestamp
      previous_activity.duration = previous_activity.end_timestamp - previous_activity.timestamp
      previous_activity.save
    end
  end

  def previous_activity
    # Added guard for double-entry
    self.previous.activities.where('(timestamp != end_timestamp OR end_timestamp IS NULL)').first
  end
  def next_activity
    # Added guard for double-entry
    self.next.activities.where('(timestamp != end_timestamp OR end_timestamp IS NULL)').first
  end
  def calculated_duration(provided_start_timestamp = nil, provided_end_timestamp = Time.zone.now)
    return [Time.zone.now, provided_end_timestamp, self.end_timestamp || Time.zone.now].min - [self.timestamp, provided_start_timestamp || self.timestamp].max
  end
  def self.recalculate_durations(user, start_time = nil, end_time = nil)
    span = user.records
    span = span.where('timestamp >= ?', start_time) if start_time
    span = span.where('timestamp <= ?', end_time) if end_time
    span.where('manual = FALSE').update_all('duration = NULL, end_timestamp = NULL')
    last_time_record = nil
    span.joins(:record_category).where(:record_categories => { :category_type => 'activity' }).readonly(false).order('timestamp DESC').each do |x|
      unless x.manual
        if last_time_record and x.end_timestamp != last_time_record.timestamp
          x.end_timestamp = last_time_record.timestamp
          if x.end_timestamp
            x.duration = x.end_timestamp - x.timestamp
          end
          x.save :validate => false
        end
      end
      last_time_record = x
    end
  end

  def private?
    self.data.to_s.downcase.include? '!private'
  end

  # Return the Tap Log Record representing an activity during which this record occurred
  def current_activity
    if self.record_category.activity?
      self
    else
      self.user.records.activities.where('timestamp < ? AND (end_timestamp IS NULL OR end_timestamp >= ?)', self.timestamp, self.timestamp).order('timestamp desc').first
    end
  end

  def during_this
    self.user.records.where('timestamp >= ? and timestamp < ? and records.id != ?', self.timestamp, self.end_timestamp, self.id).order('timestamp')
  end

  def previous
    self.user.records.where('(timestamp < ? OR (timestamp = ? AND records.id < ?))', self.timestamp, self.timestamp, self.id).order('timestamp desc, id desc')
  end

  def next
    self.user.records.where('(timestamp > ? OR (timestamp = ? AND records.id > ?))', self.timestamp, self.timestamp, self.id).order('timestamp asc, id asc')
  end

  def context
    {
      :current => self.current_activity,
      :previous => {
        :entry => self.previous.first,
        :activity => self.previous.activities.first,
      },
      :next => {
        :entry => self.next.first,
        :activity => self.next.activities.first,
      },
    }
  end
  def self.choose_zoom_level(range)
    diff = range.end.to_date - range.begin.to_date
    if diff <= 14
      :daily
    elsif diff <= 8 * 7
      :weekly
    else
      :monthly
    end
  end

  def self.get_zoom_key(user, zoom, timestamp)
    case zoom
    when :daily
      timestamp.in_time_zone.to_date
    when :weekly
      user.adjust_beginning_of_week(timestamp.to_date) + 6.days
    when :monthly
      date = timestamp.to_date
      Time.zone.local(date.year, date.month, 1).to_date
    when :yearly
      date = timestamp.to_date
      Time.zone.local(date.year, 1, 1).to_date
    end
  end

  def get_zoom_key(zoom)
    Record.get_zoom_key(self.user, zoom, self.timestamp)
  end

  def self.refresh_from_tap_log(user, file)
    start = nil
    entry = Hash.new
    min = nil
    max = nil
    list = Array.new
    CSV.foreach(file, :headers => true) do |row|
      x = Record.where('user_id=? AND source_id=? AND source_name=?', user.id, row['_id'], 'tap_log').first
      time = Time.zone.parse row['timestamp']
      # Find category
      cat = RecordCategory.find_or_create(user, [row['catOne'], row['catTwo'], row['catThree']].reject(&:blank?).compact)
      attributes = {:user => user, :timestamp => time, :record_category => cat, :data => {:number => row['number'], :rating => row['rating'], :note => row['note']}.reject { |k,v| v.blank? }, :source_id => row['_id'], :source_name => 'tap_log'}
      if time
        if x
          x.update_attributes(attributes)
        else
          x = Record.create(attributes)
        end
        min ||= time
        min = [min, time].min
        max ||= time
        max = [max, time].max
      end
      list << x
    end
    Record.recalculate_durations(user, min - 1.day, max)
    list
  end

  def self.get_entries_for_time_range(user, range)
    entries = user.records.activities.where('end_timestamp >= ? AND timestamp < ?', range.begin, range.end).order('timestamp').includes(:record_category)
    # Adjust the last entry and the first entry as needed
    if entries.count > 0 then
      entries.first.timestamp = [range.begin, entries.first.timestamp].max
      entries.first.duration = entries.first.end_timestamp - entries.first.timestamp
      entries.last.end_timestamp = [range.end, entries.last.timestamp || Time.zone.now, Time.zone.now].min
      entries.last.duration = entries.last.end_timestamp - entries.last.timestamp
    end
    entries
  end
  
  # Return an array of [date => [[start time, end time, category], [start time, end time, category]]]
  # Pre-fill colors
  def self.prepare_graph(range, records)
    result = Hash.new { |h,k| h[k] = Array.new }
    records.each do |r|
      r.split(range).each do |row|
        day = (row[0].to_date - range.begin).floor
        result[day] << row
      end
    end
    result
  end

  # Return an array of [start time, end time, record] split over multiple days or over the range
  def split(range = nil)
    if self.record_category and self.activity?
      entry_end = self.end_timestamp || Time.now
      time = range ? [self.timestamp, range.begin.midnight.in_time_zone].max : self.timestamp
      end_time = range ? [entry_end, range.end.midnight.in_time_zone].min : entry_end
      list = Array.new
      while time < end_time
        new_end = [entry_end, (time + 1.day).midnight.in_time_zone].min
        list << [time, new_end, self]
        time = new_end
      end
    else
      return [self.timestamp, nil, self]
    end
    list
  end

  # Returns an array of [string, time]
  def self.guess_time(string, options = {})
    return [nil, nil] unless string.is_a? String

    # Match hh:mm
    regex = /([0-9]+:[0-9]+)\b */
    new_string = string
    end_time = nil
    matches = new_string.match regex
    if matches
      time = Time.zone.parse(matches[1])
      new_string.sub! regex, ''
    end

    # Match the end time too if one is specified
    matches = new_string.match regex
    if matches
      end_time = Time.zone.parse(matches[1])
      new_string.sub! regex, ''
    end

    # Have we specified a date, as in batch entry?
    if options[:date] 
      time = (time || Time.now) - (Time.zone.now.to_date - options[:date].to_date).days
      if end_time
        end_time = (end_time || Time.now) - (Time.zone.now.to_date - options[:date].to_date).days
      end
    end
    
    # match -30m or -30min example, always as an offset from now
    regex = /-([\.0-9]+)(m(ins?)?|h(rs?|ours?)?)\b */
    matches = new_string.match regex
    if matches
      case matches[2]
      when "h", "hr", "hrs", "hour", "hours"
        time = (time || Time.zone.now) - matches[1].to_i.hours
      when "m", "min", "mins"
        time = (time || Time.zone.now) - matches[1].to_i.minutes
      end
      new_string.sub! regex, ''
    end

    # Match the end time too if specified
    matches = new_string.match regex
    if matches
      case matches[2]
      when "h", "hr", "hrs", "hour", "hours"
        end_time = (end_time || Time.zone.now) - matches[1].to_i.hours
      when "m", "min", "mins"
        end_time = (end_time || Time.zone.now) - matches[1].to_i.minutes
      end
      new_string.sub! regex, ''
    end

    # recognize (last)?+5m as a start time
    # if last is specified, base it on the previous activity
    regex = /(last)?\+([\.0-9]+)(m(ins?)?|h(rs?|ours?)?)\b */
    matches = new_string.match regex
    if matches
      if matches[1]
        if options[:user]
          # Get the last activity
          last_activity = options[:user].records.activities.order('timestamp desc').limit(1).first
          time = last_activity.timestamp
        end
      end
      case matches[3]
      when "h", "hr", "hrs", "hour", "hours"
        time = (time || Time.zone.now) + matches[2].to_i.hours
      when "m", "min", "mins"
        time = (time || Time.zone.now) + matches[2].to_i.minutes
      end
      new_string.sub! regex, ''
    end
    # At this point, time should be the correct time (except that it's based on today)

    # match m-d or m/d, and subtract as many days as needed to get to that date
    regex = /\b(([0-9][0-9][0-9][0-9])[-\/])?([0-9]?[0-9])[-\/]([0-9]?[0-9])\b */
    matches = new_string.scan(regex).each_with_index do |matches, i|
      year = matches[1] ? matches[1].to_i : nil
      month = matches[2].to_i
      day = matches[3].to_i
      if year
        d = Time.zone.local(year, month, day)
      else
        d = Time.zone.local(Time.zone.now.to_date.year, month, day)
        if d > Time.zone.today
          d = Time.zone.local(Time.zone.now.to_date.year - 1, month, day)
        end
      end
      if i == 0
        time = (time || Time.zone.now) - (Time.zone.now.to_date - d.to_date).days
      else
        end_time = (end_time || Time.zone.now) - (Time.zone.now.to_date - d.to_date).days
      end
    end
    new_string.gsub! regex, ''
    [new_string.strip, time, end_time]
  end

  # Turn LINES into an array of { :timetamp => Date, :category => RecordCategory or list, :text => input text }
  def self.confirm_batch(account, lines, options = {})
    if lines.is_a? String
      lines = lines.split /[\r\n]+/
    end
    list = Array.new
    lines.each_with_index do |line, i|
      # See if we need to disambiguate them
      time = Record.guess_time(line.dup, options)
      cat = RecordCategory.search(account, time[0], :activity => true)
      list << { :line_id => i, 
        :timestamp => time[1], 
        :category => cat, 
        :record_category_id => (cat.is_a?(RecordCategory) ? cat.id : nil), 
        :text => line,
        :end_timestamp => time[2]}
    end
    end_timestamp = nil
    list = list.sort { |a,b| a[:timestamp] <=> b[:timestamp] }.reverse.map { |l|
      l[:end_timestamp] ||= end_timestamp
      end_timestamp = l[:timestamp]
      l
    }.reverse
    
    next_activity = account.records.where('timestamp > ?', list.last[:timestamp]).activities.first
    if next_activity
      list.last[:end_timestamp] ||= next_activity.timestamp
    end
    list
  end

  def self.create_batch(account, records, options = {})
    list = Array.new
    records.map do |line|
      # See if we need to disambiguate them
      if line[:record_category_id] and line[:timestamp]
        list << account.records.create(:timestamp => line[:timestamp], :end_timestamp => line[:end_timestamp], :record_category_id => line[:record_category_id])
      end
    end
    if options[:set_end]
      list.sort! { |a,b| a.timestamp <=> b.timestamp }
      list.first.update_previous if list.first 
      list.last.update_next if list.last
    end
    list
  end

  def self.parse(account, attributes)
    # Look for the category
    time = nil
    if attributes[:category]
      # Copy any record data if specified
      matches = attributes[:category].match /^(.*?)\|(.*)/
      if matches
        attributes[:category] = matches[1]
        record_data = matches[2]
      end
      data = Record.guess_time(attributes[:category], user: account)
      time = data[1]
      end_time = data[2]
    end
    unless attributes[:timestamp].blank?
      if attributes[:timestamp].is_a? String
        time = Time.zone.parse(attributes[:timestamp]) if time.blank?
      else
        time = attributes[:timestamp] if time.blank?
      end
    end
    time ||= Time.now
    if attributes[:category_id]
      cat = account.record_categories.find_by_id(attributes[:category_id])
      new_record = {:user => account, :record_category => cat, :timestamp => time, :end_timestamp => end_time}
    elsif attributes[:category]
      cat = RecordCategory.search(account, data[0])
      if cat.is_a? RecordCategory
        new_record = {:user => account, :record_category => cat, :timestamp => time, :end_timestamp => end_time}
      else
        rec = cat
      end
    end
    if cat.is_a? RecordCategory
      if (record_data or attributes[:data]) and (!cat.data or cat.data.length == 0)
        cat.data = [{'key' => 'note', 'label' => 'Note', 'type' => 'string'}]
        cat.save!
      end
      if cat.data
        if record_data
          record_key = cat.data.first['key']
          if record_key
            new_record[:data] = {record_key => record_data.strip}
          end
        end
        # Get it from the parameters, too
        if attributes[:data]
          new_record[:data] ||= Hash.new
          new_record[:data].merge!(attributes[:data])
        end
      end
      rec = Record.create(new_record)
      if rec
        rec.update_previous
        rec.update_next
      end
    end
    rec
  end

  def self.get_records(account, options = {})
    if options[:order] == 'oldest'
      records = account.records.order('timestamp ASC')
    else
      records = account.records.order('timestamp DESC')
    end
    if options[:start] and options[:end]
      records = records.where(:timestamp => options[:start]..options[:end])
    end
    unless options[:filter_string].blank?
      query = "%" + options[:filter_string].downcase + "%"
      records = records.joins(:record_category).where('LOWER(records.data) LIKE ? OR LOWER(record_categories.full_name) LIKE ?', query, query)
    end
    unless options[:include_private]
      records = records.public_records
    end
    records = records.joins(:record_category).select('records.*, record_categories.full_name, record_categories.color, record_categories.name, record_categories.parent_id, record_categories.category_type')
    records
  end

  delegate :activity_type, to: :record_category
  delegate :activity?, :to => :record_category
  delegate :full_name, :to => :record_category
  delegate :get_color, :to => :record_category
  delegate :color, :to => :record_category

  comma do
    timestamp { |timestamp| I18n.l(timestamp, :format => :long) if timestamp }
    end_timestamp { |timestamp| I18n.l(timestamp, :format => :long) if timestamp }
    record_category :full_name => 'Record category'
    record_category :id => 'Record category ID'
    record_category :category_type => 'Record category type'
    duration
    source_name
    source_id
    data 'Data' do |data| data.to_json if data and data.size > 0 end
    timestamp 'Day' do |t| t.strftime('%Y-%m-%d') end
    beginning_of_week 'Beginning of week'
    timestamp 'Beginning of month' do |t| Time.zone.local(t.year, t.month, 1).strftime('%Y-%m-%d') end
    timestamp 'Beginning of year' do |t| Time.zone.local(t.year, 1, 1).strftime('%Y-%m-%d') end
  end

  def beginning_of_week
    self.user.adjust_beginning_of_week(self.timestamp).strftime('%Y-%m-%d')
  end

  fires :new, :on => :create, :actor => :user, :secondary_subject => :record_category

end
