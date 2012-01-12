class ClothingLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :clothing, :counter_cache => true
  has_and_belongs_to_many :clothing_matches, \
  :class_name => "ClothingLog", \
  :join_table => "clothing_matches", \
  :foreign_key => :clothing_log_a_id, \
  :association_foreign_key => :clothing_log_b_id, \
  :readonly => true

  after_save :update_matches
  after_destroy :delete_matches

  def update_matches
    logger.info "Updating matches..."
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
end
