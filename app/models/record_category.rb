class RecordCategory < ActiveRecord::Base
  require 'comma'
  acts_as_tree_with_dotted_ids :order => "name"
  has_many :records
  belongs_to :user
  before_save :add_data
  serialize :data
  validates_presence_of :name
  validates_presence_of :category_type

  after_initialize do
    if self.new_record?
      # values will be available for new record forms.
      self.active = true 
    end
  end
  
  def add_data
    self.full_name = self_and_ancestors.reverse.map{ |c| c.name }.join(' - ').html_safe
  end

  # :tree =>
  #    :full - parent totals include that of child categories, show all categories below this
  #    :next_level - only the next level of children is shown
  #    other - each entry counts only towards its own category
  def self.roll_up_records(options = {})
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3] = 0 } } }
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
        x if ((x.end_timestamp >= options[:range].begin) and (x.timestamp < options[:range].end))
      }.compact
    end
    # Filter by categories
    parent = options[:parent]
    categories = user.record_categories.select('color, id, full_name, category_type, dotted_ids').index_by(&:id)
    if parent
      all_children = parent.all_children.index_by(&:id)
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
          if categories[rec.record_category_id].dotted_ids
            ids = categories[rec.record_category_id].dotted_ids.split('.')
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
        summary[:total][:total][key] += rec.duration
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
        cat.update_attributes(:category_type => 'list')
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
    self.user.records.joins(:record_category).where('dotted_ids LIKE ?', self.dotted_ids + '.%')
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
    x = self
    while x != nil
      return x.color unless x.color.blank?
      x = x.parent
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
    self.user.records.joins(:record_category).where('(record_categories.dotted_ids = ? OR record_categories.dotted_ids LIKE ?)', self.dotted_ids, self.dotted_ids + ".%")
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
      duration += (range ? range.end : Time.zone.now) - last.timestamp
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
    else
      records = records.order('timestamp DESC')
    end
    unless options[:include_private]
      records = records.public
    end
    if options[:filter_string]
      query = "%" + options[:filter_string].downcase + "%"
      records = records.where('LOWER(records.data) LIKE ?', query) 
    end
    records
  end
  
  # CSV support
  comma do
    id
    name
    category_type
    full_name
    color
    parent_id
    dotted_ids
    data 'Data' do |data| data.to_json if data and data.size > 0 end
  end
  
  scope :active, where(:active => true)
end
