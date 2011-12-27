class RecordCategory < ActiveRecord::Base
  acts_as_tree_with_dotted_ids :order => "name"
  has_many :records
  belongs_to :user
  before_save :add_data
  serialize :data
  def add_data
    self.full_name = self_and_ancestors.reverse.map{ |c| c.name }.join(' - ').html_safe
  end

  def self.roll_up_records(options = {})
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3] = 0 } } }
    records = options[:records]
    max = Time.now
    zoom = options[:zoom]
    if options[:range]
      records = records.where(:timestamp => options[:range])
      max = options[:range].end.midnight.in_time_zone
      min = options[:range].begin.midnight.in_time_zone
    end
    records = records.activities
    records.each do |rec|
      split = rec.split(options[:range])
      case options[:tree]
      when :full
        categories = rec.record_category.self_and_ancestors
      when :next_level
        categories = [rec.record_category.as_child(options[:parent])].compact
      else
        categories = [rec.record_category]
      end
      if categories.length > 0
        split.each do |split_record|
          key = Record.get_zoom_key(options[:user], zoom, split_record[0])
          categories.each do |cat|
            summary[:rows][cat][key] += split_record[1] - split_record[0]
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
    options[:range] ||= records.min('timestamp')..records.max('timestamp')
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

  def self.search(account, string)
    list = account.record_categories.where('LOWER(full_name) LIKE LOWER(?)', "%#{string.downcase}%").order('dotted_ids')
    return list.first if list.length == 1
    return nil if list.length == 0
    # Ambiguous match; search again with >
    new_list = account.record_categories.where('LOWER(full_name) LIKE LOWER(?)', "> %#{string.downcase}%")
    return new_list.first if new_list.length == 1
    return list.first  # Fall-through
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
end
