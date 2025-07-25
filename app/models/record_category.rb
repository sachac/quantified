require 'ancestry'
class RecordCategory < ApplicationRecord
  require 'comma'
  has_ancestry
  serialize :data
  has_many :records
  belongs_to :user
  before_save :add_data
  validates_presence_of :name
  validates_presence_of :category_type
  belongs_to :record_category, optional: true, foreign_key: 'parent_id'
  has_many :record_categories

  after_initialize do
    if self.new_record?
      # values will be available for new record forms.
      self.active = true 
    end
  end
  
  def add_data
    self.full_name = ancestors.map{ |c| c.name }.join(' - ').html_safe + ' - ' + self.name
  end

  def update_data(data_fields)
    do_rename = false
    data_fields.each do |row|
      if row['oldkey'] and row['key'] != row['oldkey']
        do_rename = true
      end
    end
    if do_rename
      self.records.each do |record|
        if record.data
          data_fields.each do |row|
            if row['oldkey'] and row['key'] != row['oldkey']
              record.data[row['key']] = record.data[row['oldkey']]
              record.data.delete(row['oldkey'])
            end
          end  
          record.save!
        end
      end
    end
    self.data = data_fields
  end
  
  # :tree =>
  #    :full - parent totals include that of child categories, show all categories below this
  #    :next_level - only the next level of children is shown
  #    other - each entry counts only towards its own category
  def self.roll_up_records(options = {})
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3] = 0 } } }
    summary[:total][:total][:total] = 0
    records = options[:records]
    user = options[:user]
    max = Time.now
    zoom = options[:zoom]
    records ||= user.records
    records = records.activities.select('records.id, records.record_category_id, records.timestamp, records.end_timestamp')
    # Limit by range
    if options[:range]
      max = options[:range].end.midnight.in_time_zone
      min = options[:range].begin.midnight.in_time_zone
      options[:range] = min..max
      records = records.where('(end_timestamp IS NULL OR end_timestamp >= ?) AND timestamp < ?', options[:range].begin, options[:range].end)
    end
    # Split by midnight if needed, get rid of anything outside the range
    records = Record.split(records)
    if options[:range]
      records = records.map { |x| 
        x.end_timestamp ||= Time.now
        x if ((x.end_timestamp > options[:range].begin) and (x.timestamp < options[:range].end))
      }.compact
    end
    # Filter by categories
    parent = options[:parent]
    categories = user.record_categories.select('color, id, full_name, category_type, ancestry').index_by(&:id)
    if parent
      all_children = parent.descendants.index_by(&:id)
    end
    # Cache the record categories for performance instead of retrieving them one at a time
    records.each do |rec|
      ids = nil
      if parent and rec.record_category_id != parent.id and !all_children[rec.record_category_id]
        next
      end
      if categories[rec.record_category_id]
        case options[:tree]
        when :full
          if categories[rec.record_category_id].has_attribute?(:ancestry) and categories[rec.record_category_id].ancestry
            ids = categories[rec.record_category_id].ancestry.split('/')
            ids.append(rec.record_category_id)
          else
            ids = [rec.record_category_id]
          end
        when :next_level
          if options[:parent]
            ids = [rec.record_category.as_child(options[:parent])].compact.map(&:id)
          else
            ids = [rec.record_category.as_child(nil)].compact.map(&:id)
          end
        else
          ids = [rec.record_category_id]
        end
      end
      if ids and ids.length > 0
        key = Record.get_zoom_key(options[:user], zoom, rec.timestamp)
        ids.each do |cat|
          cat = cat.to_i
          case options[:key]
          when :date
            summary[:rows][key][cat] += rec.duration
          else
            summary[:rows][cat][key] += rec.duration
          end
          summary[:rows][cat][:total] += rec.duration
        end
        summary[:cols][key][:total] += rec.duration
        summary[:total][:total][key] += rec.duration
        summary[:total][:total][:total] += rec.duration
      end
    end
    summary
  end
    
  def self.find_or_create(user, path)
    count = path.length
    parent = nil
    cat = nil
    path.each_with_index do |p, i|
      return cat if p.blank?
      if parent
        cat = parent.children.find_by_name(p)
      else
        cat = user.record_categories.where('name = ? AND parent_id IS NULL', p).first
      end
      unless cat
        cat = user.record_categories.create(:name => p, :category_type => (i == count - 1) ? 'record' : 'list', :user => user, :parent => parent)
      end
      if (i < count - 1) and !cat.list?
        cat.category_type = 'list'
      end
      parent = cat
    end
    cat
  end
  
  def self.summarize(options = {})
    options[:records] ||= options[:user].records
    options[:zoom] ||= Record.choose_zoom_level(options[:range])
    self.roll_up_records(options)
  end

  def summarize(options = {})
    return if self.record?
    if self.activity?
      records = self.records
    else
      records = self.tree_records
    end
    RecordCategory.summarize(options.merge(user: self.user, records: records, parent: self))
  end
  
  def activity?
    self.category_type == 'activity'
  end

  def list?
    self.category_type == 'list'
  end

  def record?
    self.category_type == 'record'
  end

  def tree_records
    self.user.records.joins(:record_category).where('(record_categories.ancestry = ? OR record_categories.ancestry LIKE ?)', if self.ancestry then self.ancestry + '/' + self.id.to_s else self.id.to_s end, if self.ancestry then self.ancestry + '/' + self.id.to_s + '/%' else self.id.to_s + '/%' end)
  end

  # Given: 1.2.3, 1.2.3.4.5, return 4 (the next-level child of parent)
  # Given: 1.2.3, 4, return nil (item is not a child of parent)
  # Given: 1.2.3, 1.2.3, return ''
  def self.as_child_id(parent, child)
    if parent == child
      return ''
    end
    if child[0, parent.length + 1] == parent + "."
      child[parent.length + 1, child.length - parent.length].split('.')[0]
    end
  end

  # Returns this category as a child of parent
  def as_child(parent)
    x = self
    return x if x == parent 
    while x.parent and x.parent != parent
      x = x.parent
    end
    if x.parent == parent
      x
    end
  end
  
  def get_color
    seen = []
    x = self
    while x != nil
      return x.color unless x.color.blank?
      seen.push x.id
      x = x.parent
      if x != nil and seen.include? x.id
        x = nil
      end
    end
  end

  def self.search(account, string, options = {})
    split = string.downcase.split
    list = account.record_categories.active
    split.each do |l|
      list = list.where('LOWER(full_name) LIKE LOWER(?)', "%#{l.strip}%")
    end
    if options[:activity]
      list = list.where('category_type = ?', 'activity')
    end
    return list.first if list.length == 1
    return nil if list.length == 0
    # Ambiguous match; search again with >
    new_list = account.record_categories.where('LOWER(full_name) LIKE LOWER(?)', "> %#{string.downcase}%")
    return new_list.first if new_list.length == 1
    return list # More than one - fallthrough
  end

  def child_records
    self.user.records.joins(:record_category).where('(record_categories.ancestry = ? OR record_categories.ancestry LIKE ?)', if self.ancestry then self.ancestry + '/' + self.id.to_s else self.id.to_s end, if self.ancestry then self.ancestry + '/' + self.id.to_s + '/%' else self.id.to_s + '/%' end)
  end

  def cumulative_time(range = nil)
    records = self.child_records.activities
    if range then
      records = records.where('(end_timestamp IS NULL OR end_timestamp >= ?) AND timestamp < ?', range.begin, range.end)
    end
    duration = records.sum(:duration)
    begin_time = range ? range.begin : records.minimum(:timestamp)
    end_time = range ? range.end : Time.zone.now
    # Add the duration of any open entries
    last = records.order('timestamp DESC').first
    if last and last.end_timestamp.nil?
      duration += [range.end, Time.zone.now].min - last.timestamp
    elsif last and last.end_timestamp > end_time
      # Split the last entry
      duration -= (last.end_timestamp - end_time)
    end
   
    # Split the previous entry if needed
    previous = records.order('timestamp ASC').first
    if previous and previous.timestamp < begin_time
      duration -= begin_time - previous.timestamp
    end

    duration
  end
  
  # order: newest, oldest
  # start
  # end
  # filter_string
  def category_records(options = {})
    if self.list?
      records = self.tree_records
    else
      records = self.records
    end
    if options[:start] and options[:end]
      records = records.where("timestamp >= ?", options[:start]).where("timestamp <= ?", options[:end])
    end
    if options[:order] == 'oldest'
      records = records.order('timestamp ASC')
    elsif options[:order] == 'newest'
      records = records.order('timestamp DESC')
    end
    unless options[:include_private]
      records = records.public_records
    end
    if !options[:filter_string].blank?
      query = "%" + options[:filter_string].downcase + "%"
      records = records.joins(:record_category).where('LOWER(records.data) LIKE ? OR LOWER(record_categories.full_name) LIKE ?', query, query) 
    end
    records
  end

  # Summarize this record category and its children
  # Returns a hash of :last_entry, :duration (minutes), :recent_entries (list)
  def status
    results = {}
    records = self.category_records(include_private: true, order: 'newest')
    start_day = Time.zone.now.midnight
    end_day = Time.zone.now.midnight + 1.day
    results[:last_entry] = records.first
    results[:recent_entries] = records.where('(timestamp >= ? AND timestamp < ?) OR (timestamp < ? AND end_timestamp IS NULL)', start_day, end_day, start_day).all
    results[:duration] = results[:recent_entries].map {|x| x.calculated_duration(start_day, end_day) }.reduce(0, :+)
    return results
  end
  
  # CSV support
  comma do
    id
    name
    category_type
    full_name
    color
    parent_id
    ancestry
    data 'Data' do |data| data.to_json if data and data.size > 0 end
  end

  scope :lookup, lambda { |x| if x.match(/\A\d+\Z/) then where("id = ?", x.to_i) else where("full_name = ?", x) end }
  scope :active, -> { where active: true }
end
