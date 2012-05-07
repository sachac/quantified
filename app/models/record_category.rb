class RecordCategory < ActiveRecord::Base
  acts_as_tree_with_dotted_ids :order => "name"
  has_many :records
  belongs_to :user
  before_save :add_data
  serialize :data
  validates_presence_of :name
  validates_presence_of :category_type
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
    if options[:range]
      records = records.where(:timestamp => options[:range])
      max = options[:range].end.midnight.in_time_zone
      min = options[:range].begin.midnight.in_time_zone
    end
    records ||= user.records
    records = records.activities
    categories = user.record_categories.index_by(&:id)
    # Cache the record categories for performance instead of retrieving them one at a time
    records.each do |rec|
      ids = nil
      if categories[rec.record_category_id]
        case options[:tree]
        when :full
          if categories[rec.record_category_id].dotted_ids
            ids = categories[rec.record_category_id].dotted_ids.split('.')
          end
        when :next_level
          if options[:parent]
            ids = [rec.record_category.as_child(options[:parent].dotted_ids)].compact.map(&:id)
          else
            ids = [rec.record_category.as_child(nil)].compact.map(&:id)
          end
        else
          ids = [rec.record_category_id]
        end
      end
      if ids.length > 0
        rec.split(options[:range]).each do |split_record|
          key = Record.get_zoom_key(options[:user], zoom, split_record[0])
          ids.each do |cat|
            case options[:key]
            when :date
              summary[:rows][key][categories[cat.to_i]] += split_record[1] - split_record[0]
            else
              summary[:rows][categories[cat.to_i]][key] += split_record[1] - split_record[0]
            end
          end
          summary[:total][:total][key] += split_record[1] - split_record[0]
        end
      end
    end
    summary
  end
    
  def self.find_or_create(user, path)
    count = path.length
    parent = nil
    cat = nil
    logger.info path.inspect
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
    RecordCategory.summarize(self.user, :records => records, :parent => self)
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
    Record.joins(:record_category).where('dotted_ids LIKE ?', self.dotted_ids + '.%')
  end

  # Given: 1.2.3, 1.2.3.4.5, return 4 (the next-level child of parent)
  # Given: 1.2.3, 4, return nil (item is not a child of parent)
  def self.as_child_id(parent, child)
    if child[0, parent.length + 1] == parent + "."
      child[parent.length + 1, child.length - parent.length].split('.')[0]
    end
  end
  def as_child_id(parent)
    # If this category is a descendant of parent, return the next level in the category tree below parent
    id = Record.as_child_id(parent, self.dotted_ids)
    if parent.is_a? RecordCategory
      return RecordCategory.find_by_id(id) if id 
    else
      return id
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
    list = account.record_categories
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

  def data_description
    if self.data
      self.data.map { |key, info|
        "#{key}: #{info[:type]}: #{info[:label]}"
      }.join "\n"
    end
  end

  def data_description=(value)
    self.data = Hash.new
    value.split("\n").each do |line|
      match = line.match(/^([^:]+): *([^:]+): *(.*)/)
      self.data[match[1].to_sym] = {:type => match[2], :label => match[3]} 
    end
  end

  def child_records
    self.user.records.joins(:record_category).where('(record_categories.dotted_ids = ? OR record_categories.dotted_ids LIKE ?)', self.dotted_ids, self.dotted_ids + ".%")
  end

  def cumulative_time(range)
    records = self.child_records.activities
    filtered = records.where(:timestamp => range)
    duration = filtered.sum(:duration)

    # Add the duration of any open entries
    last = filtered.order('timestamp DESC').first
    if last and last.end_timestamp.nil?
      duration += range.end - last.timestamp
    elsif last and last.end_timestamp > range.end
      # Split the last entry
      duration -= (last.end_timestamp - range.end)
    end
   
    # Split the previous entry if needed
    previous = records.where('timestamp < ?', range.begin).order('timestamp DESC').first
    if previous and previous.end_timestamp and previous.end_timestamp > range.begin
      duration += previous.end_timestamp - range.begin
    end

    duration
  end
end
