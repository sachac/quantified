class ClothingMatch < ActiveRecord::Base
  belongs_to :user
  belongs_to :clothing_a, :class_name => "Clothing"
  belongs_to :clothing_b, :class_name => "Clothing"
  belongs_to :clothing_log_a, :class_name => "ClothingLog"
  belongs_to :clothing_log_b, :class_name => "ClothingLog"
  def self.recreate(object)
    self.delete_matches(object)
    # Recreate matches for this date
    if (object.is_a? ClothingLog) then
      object.user.reload.clothing_logs.where('clothing_id != ? AND outfit_id = ? AND date = ?', object.clothing_id, object.outfit_id, 
                                             (object.date.is_a?(Time) ? object.date.in_time_zone.to_date : object.date)).each do |l|
        ClothingMatch.create!(clothing_a_id: object.clothing_id, clothing_b_id: l.clothing_id, 
          clothing_log_a_id: object.id, clothing_log_b_id: l.id, user_id: object.user_id, clothing_log_date: object.date)
        ClothingMatch.create!(clothing_b_id: object.clothing_id, clothing_a_id: l.clothing_id, 
          clothing_log_b_id: object.id, clothing_log_a_id: l.id, user_id: object.user_id, clothing_log_date: object.date)
      end
    else
      object.clothing_logs.each do |l|
        self.recreate(l)
      end      
    end
  end
  def self.delete_matches(clothing_or_clothing_log)
    if clothing_or_clothing_log.is_a? ClothingLog then
      ClothingMatch.delete_all(['clothing_log_a_id = ? OR clothing_log_b_id = ?', clothing_or_clothing_log.id, clothing_or_clothing_log.id])
    elsif clothing_or_clothing_log.is_a? Clothing then
      ClothingMatch.delete_all(['clothing_a_id = ? OR clothing_b_id = ?', clothing_or_clothing_log.id, clothing_or_clothing_log.id])
    end
  end
  def self.flush
    ClothingMatch.delete_all
    by_date = Hash.new
    ClothingLog.all.each do |l|
      date = (l.date.is_a?(Time) ? l.date.in_time_zone.to_date : l.date)
      by_date[date] ||= Hash.new
      by_date[date][l.outfit_id || 1] ||= Array.new
      by_date[date][l.outfit_id || 1] << l
    end
    by_date.each do |date, outfits|
      outfits.each do |outfit_id, list|
        0.upto(list.size - 2) do |i|
          a_id = list[i].clothing_id
          (i + 1).upto(list.size - 1) do |j|
            x = ClothingMatch.new(:clothing_a_id => a_id, :clothing_b_id => list[j].clothing_id, :clothing_log_a_id => list[i].id, :clothing_log_b_id => list[j].id)
            x.save
            x = ClothingMatch.new(:clothing_b_id => a_id, :clothing_a_id => list[j].clothing_id, :clothing_log_b_id => list[i].id, :clothing_log_a_id => list[j].id)
            x.save
          end
        end
      end
    end

  end
  
  delegate :name, :to => :clothing_a, :prefix => true
  delegate :name, :to => :clothing_b, :prefix => true
  delegate :id, :to => :clothing_a, :prefix => true
  delegate :id, :to => :clothing_b, :prefix => true
  def to_xml(options = {})
    super(options.update(:methods => [:clothing_a_id, :clothing_a_name, :clothing_b_id, :clothing_b_name]))
  end

  def self.prepare_graph(user, range = nil)
    if range
      clothing = user.clothing.joins(:clothing_matches).where('clothing_log_date >= ? AND clothing_log_date < ?', range.begin, range.end).group('clothing.id')
    else
      clothing = user.clothing.joins(:clothing_matches).select('distinct(clothing.id)')
    end
    # Get all the unique clothes included in these matches
    matches = user.clothing_matches.range(range).where('clothing_a_id < clothing_b_id')
              .select('clothing_a_id, clothing_b_id, count(clothing_b_id) AS count_matches')
              .group('clothing_a_id, clothing_b_id')
              .map { |x| {source: x.clothing_a_id, target: x.clothing_b_id, count_matches: x.count_matches} }
    {clothing: clothing.to_a, matches: matches}
  end

  def as_json(options = {})
    super(options.update(:methods => [:clothing_a_id, :clothing_a_name, :clothing_b_id, :clothing_b_name]))
  end
  
  comma do
    user_id
    clothing_log_date
    clothing_log_a_id
    clothing_a 'Clothing A ID' do |x| x.id if x end
    clothing_a 'Clothing A name' do |x| x.name if x end
    clothing_log_b_id
    clothing_b 'Clothing B ID' do |x| x.id if x end
    clothing_b 'Clothing B name' do |x| x.name if x end
  end

  scope :range, lambda { |range| range ? where('clothing_log_date >= ? AND clothing_log_date < ?', range.begin, range.end) : all }

end
