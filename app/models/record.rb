class Record < ActiveRecord::Base
  belongs_to :record_category
  belongs_to :user
  serialize :data
  scope :activities, joins(:record_category).where(:record_categories => {:category_type => 'activity'}).readonly(false)
  scope :public, where("LOWER(records.data) NOT LIKE '%!private%'")
  before_save :add_data
  def add_data
    self.date = self.timestamp.in_time_zone.to_date
  end

  def self.recalculate_durations(user, start_time = nil, end_time = nil)
    span = user.records
    span = span.where('timestamp >= ?', start_time) if start_time
    span = span.where('timestamp <= ?', end_time) if end_time
    span.update_all('duration = NULL, end_timestamp = NULL')
    last_time_record = nil
    span.joins(:record_category).where(:record_categories => { :category_type => 'activity' }).readonly(false).order('timestamp DESC').each do |x|
      x.update_attributes(:end_timestamp => last_time_record.timestamp, :duration => last_time_record.timestamp - x.timestamp) if last_time_record
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
    self.user.records.where('timestamp <= ? and records.id < ?', self.timestamp, self.id).order('timestamp desc, id desc')
  end

  def next
    self.user.records.where('timestamp >= ? and records.id > ?', self.timestamp, self.id).order('timestamp asc, id asc')
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
      new Date(date.year, date.month, 1)
    when :yearly
      date = timestamp.to_date
      new Date(date.year, 1, 1)
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
    colors = Hash.new
    records.each do |r|
      r.split(range).each do |row|
        unless row[2].color
          colors[row[2].record_category_id] ||= row[2].record_category.get_color
          row[2].record_category.color = colors[row[2].record_category_id]
        end
        result[row[0].to_date - range.begin] << row
      end
    end
    result
  end

  # Return an array of [start time, end time, category] split over multiple days or over the range
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

  def update_previous
    Record.update_last(self.user, self.timestamp)
  end

  def self.update_last(account, timestamp)
    last = account.records.activities.where('timestamp < ?', timestamp).order('timestamp DESC').first
    if last
      last.update_attributes(:end_timestamp => timestamp, :duration => timestamp - last.timestamp)
    end
  end

  # If unambiguous, create an entry based on string
  # String can be of the form hh:mm category words
  def self.create_from_query(account, string, options = {})
    matches = string.match /([0-9]+:[0-9]+) */
    if options[:timestamp] and options[:timestamp].is_a? String
      time = Time.zone.parse(options[:timestamp])
    elsif options[:timestamp]
      time = options[:timestamp]
    else
      time = Time.now
    end
    if matches
      time = Time.zone.parse(matches[1])
      string.gsub! /([0-9]+:[0-9]+) */, ''
    end
    cat = RecordCategory.search(account, string)
    if cat and cat.is_a? RecordCategory
      record = account.records.create(:timestamp => time, :record_category => cat, :user => account)
      if cat.activity?
        Record.update_last(account, record.timestamp)
      end
      return record
    else
      # Return results so the controller can figure out what to do
      return cat
    end
  end

  delegate :activity?, :to => :record_category
  delegate :full_name, :to => :record_category
  delegate :get_color, :to => :record_category
  delegate :color, :to => :record_category
end
