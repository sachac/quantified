class ClothingLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :clothing, :counter_cache => true
  has_and_belongs_to_many :clothing_matches, \
                          :class_name => "ClothingLog", \
                          :join_table => "clothing_matches", \
                          :foreign_key => :clothing_log_a_id, \
                          :association_foreign_key => :clothing_log_b_id
  
  after_save :update_matches
  after_destroy :delete_matches
  validates_presence_of :date
  validates_presence_of :clothing_id
  validates_presence_of :user_id

  def update_matches
    logger.info "Updating matches for #{self.inspect}"
    # Delete old matches
    ClothingMatch.recreate(self)
    Clothing.reset_counters self.clothing_id, :clothing_logs
    if (self.clothing_id_was) then
      Clothing.reset_counters self.clothing_id_was, :clothing_logs
    end
    # Update the counts, too
    self.clothing.update_stats!.save
    if self.clothing_id_changed? and self.clothing_id_was
      self.user.clothing.find(self.clothing_id_was).update_stats!.save
    end
  end

  def delete_matches
    Clothing.reset_counters self.clothing_id, :clothing_logs
    Clothing.reset_counters self.clothing_id_was, :clothing_logs
    # Update counts and last worn date
    self.clothing.update_stats!.save
    ClothingMatch.delete_matches(self)
  end

  def self.by_date(query)
    by_date = Hash.new
    query.each do |l|
      by_date[l.date] ||= Array.new
      by_date[l.date] << l
    end
    by_date
  end

  # Accepts records, zoom
  def self.summarize(options = {})
    result = Hash.new { |h,k| h[k] = {sums: {}, total: 0} } 
    user = options[:user]
    options[:records].each do |r|
      id = r.clothing_id
      date = r.date
      case options[:zoom]
      when 'weekly'
        date = user.adjust_end_of_week(r.date).to_date
      when 'monthly'
        date = user.adjust_end_of_month(r.date)
      when 'yearly'
        date = user.adjust_end_of_year(r.date)
      end
      date = date.to_date
      if result[id][:sums][date] 
        result[id][:sums][date] += 1
      else
        result[id][:sums][date] = 1
      end
      result[id][:total] += 1
    end
    result
  end

  delegate :name, :to => :clothing, :prefix => true
  def to_xml(options = {})
    super(options.update(:methods => [:clothing_name]))
  end
  
  def as_json(options = {})
    super(options.update(:methods => [:clothing_name]))
  end
  
  def end_of_month
    self.user.adjust_end_of_month(date)
  end
  def end_of_week
    self.user.adjust_end_of_week(date)
  end
  def end_of_year
    self.user.adjust_end_of_year(date)
  end
  comma do
    clothing_id
    date
    outfit_id
    clothing :name
    end_of_week
    end_of_month
    end_of_year
  end

  fires :new, :on => :create, :actor => :user, :secondary_subject => :clothing
  private
  def clothing_log_params
    params.require(:clothing_id, :date).permit(:outfit_id)
  end
end
