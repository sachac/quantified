class Record < ActiveRecord::Base
  belongs_to :record_category
  belongs_to :user
  serialize :data
  scope :activities, joins(:record_category).where(:record_categories => {:category_type => 'activity'}).readonly(false)
  scope :public, where("LOWER(records.data) NOT LIKE '%!private%'")
  before_save :add_data
  validate :end_timestamp_must_be_after_start
 
  def end_timestamp_must_be_after_start
    if !end_timestamp.blank? and end_timestamp < timestamp
      errors.add(:end_timestamp, 'must be after beginning of record')
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
    if !self.manual
      next_activity = self.next_activity
      if next_activity and self.end_timestamp and next_activity.timestamp != self.end_timestamp
        next_act = Record.where(:id => next_activity.id)
        next_act.update_all(['timestamp = ?', self.end_timestamp])
        if next_activity.end_timestamp
          next_act.update_all(['duration = ?', next_activity.timestamp])
        end
      end
    end
  end
  def update_previous
    previous_activity = self.previous_activity
    if previous_activity and !previous_activity.manual? and (!previous_activity.end_timestamp or previous_activity.end_timestamp != self.timestamp)
      prev = Record.where(:id => previous_activity.id)
      prev.update_all(['end_timestamp = ?', self.timestamp])
      prev.update_all(['duration = ?', self.timestamp - previous_activity.timestamp])
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
      self.user.records.activities.where('timestamp < ?', self.timestamp).order('timestamp desc').first
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
    elsif diff <= 365
      :monthly
    else
      :yearly
    end
  end

  def self.get_zoom_key(user, zoom, timestamp)
    case zoom
    when :daily
      timestamp.to_date
    when :weekly
      user.adjust_beginning_of_week(timestamp.to_date) + 6.days
    when :monthly
      date = timestamp.to_date
      Date.new(date.year, date.month, 1)
    when :yearly
      date = timestamp.to_date
      Date.new(date.year, 1, 1)
    end
  end

  def get_zoom_key(zoom)
    Record.get_zoom_key(self.user, zoom, self.timestamp)
  end

  def self.refresh_from_tap_log(user, file)
    start = nil
    entries = Array.new
    unrecognized = Array.new
    entry = Hash.new
    min = nil
    max = nil
    FasterCSV.foreach(file, :headers => true) do |row|
      x = Record.where('user_id=? AND source_id=? AND source=?', user.id, row['_id'], 'tap_log').first
      time = Time.zone.parse row['timestamp']
      # Find category
      cat = RecordCategory.find_or_create(user, [row['catOne'], row['catTwo'], row['catThree']].reject(&:blank?).compact)
      attributes = {:user => user, :timestamp => time, :record_category => cat, :data => {:number => row['number'], :rating => row['rating'], :note => row['note']}.reject { |k,v| v.blank? }, :source_id => row['_id'], :source => 'tap_log'}
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
    end
    Record.recalculate_durations(user, min - 1.day, max)
  end

  # Return an array of [date => [[start time, end time, category], [start time, end time, category]]]
  # Pre-fill colors
  def self.prepare_graph(range, records)
    result = Hash.new { |h,k| h[k] = Array.new }
    records.each do |r|
      r.split(range).each do |row|
        day = row[0].to_date - range.begin
        result[day] << row
      end
    end
    result
  end

  # Return an array of [start time, end time, record] split over multiple days or over the range
  def split(range = nil)
    entry_end = self.end_timestamp || Time.now
    time = range ? [self.timestamp, range.begin.midnight.in_time_zone].max : self.timestamp
    end_time = range ? [entry_end, range.end.midnight.in_time_zone].min : entry_end
    list = Array.new
    while time < end_time
      new_end = [entry_end, (time + 1.day).midnight.in_time_zone].min
      list << [time, new_end, self]
      time = new_end
    end                     
    list
  end

  # Returns an array of [string, time]
  def self.guess_time(string, options = {})
    return [nil, nil] unless string.is_a? String
    # Match hh:mm
    regex = /([0-9]+:[0-9]+)\b */
    matches = string.match regex
    new_string = string
    time = Time.now
    if matches
      time = Time.zone.parse(matches[1])
      new_string.gsub! regex, ''
    end
    if options[:date] 
      time = time - (Date.today - options[:date]).days
    end
      

    # match -30m or -30min example, always as an offset from now
    regex = /-([\.0-9]+)(m(ins?)?|h(rs?|ours?)?)\b */
    matches = new_string.match regex
    if matches
      case matches[2]
      when "h", "hr", "hrs", "hour", "hours"
        time = time - matches[1].to_i.hours
      when "m", "min", "mins"
        time = time - matches[1].to_i.minutes
      end
      new_string.gsub! regex, ''
    end
    # match m-d or m/d
    regex = /\b([0-9]?[0-9])[-\/]([0-9]?[0-9])\b */
    matches = new_string.match regex
    if matches
      d = Date.new(Date.today.year, matches[1].to_i, matches[2].to_i)
      if d > Date.today
        d = Date.new(Date.today.year - 1, matches[1].to_i, matches[2].to_i)
      end
      time = time - (Date.today - d).days
      new_string.gsub! regex, ''
    end
    [new_string.strip, time]
  end
  # If unambiguous, create an entry based on string
  # String can be of the form hh:mm category words
  def self.create_from_query(account, string, options = {})
    cat = RecordCategory.search(account, string)
    if cat and cat.is_a? RecordCategory
      record = account.records.create(:timestamp => time, :record_category => cat, :user => account)
      return record
    else
      # Return results so the controller can figure out what to do
      return cat
    end
  end

  # Turn LINES into an array of { :time => Date, :category => RecordCategory or list, :text => input text }
  def self.confirm_batch(account, lines, options = {})
    if lines.is_a? String
      lines = lines.split /[\r\n]+/
    end
    list = Array.new
    lines.each_with_index do |line, i|
      # See if we need to disambiguate them
      time = Record.guess_time(line.dup, options)
      cat = RecordCategory.search(account, time[0], :activity => true)
      list << { :line_id => i, :timestamp => time[1], :category => cat, :record_category_id => (cat.is_a?(RecordCategory) ? cat.id : nil), :text => line }
    end
    end_timestamp = nil
    list = list.sort { |a,b| a[:timestamp] <=> b[:timestamp] }.reverse.map { |l|
      l[:end_timestamp] = end_timestamp
      end_timestamp = l[:timestamp]
      l
    }.reverse
    
    next_activity = account.records.where('timestamp > ?', list.last[:timestamp]).activities.first
    if next_activity
      list.last[:end_timestamp] = next_activity.timestamp
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
      list.first.update_previous
      list.last.update_next
    end
  end

  delegate :activity?, :to => :record_category
  delegate :full_name, :to => :record_category
  delegate :get_color, :to => :record_category
  delegate :color, :to => :record_category
end
