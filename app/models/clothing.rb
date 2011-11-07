class Clothing < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable_on :tags
  has_many :clothing_logs
  has_and_belongs_to_many :clothing_matches, \
  :class_name => "Clothing", \
  :join_table => "clothing_matches", \
  :foreign_key => :clothing_a_id, \
  :association_foreign_key => :clothing_b_id, \
  :readonly => true
 
  before_save :update_hsl
  def autocomplete_view
    "#{self.id} - #{self.name}"
  end
  def update_hsl
    c = self.get_color
    unless c.nil? then
      hsl = c.to_hsl
      self.hue = hsl.h
      self.saturation = hsl.s
      self.brightness = hsl.l
    end
  end

  def get_color
    base = self.colour.split(',')[0] unless self.colour.blank? 
    unless base.nil? then
      Color::RGB.from_html(base)
    end
  end

  def update_stats!
    last = self.clothing_logs.order('date DESC').first
    if last then
      self.last_worn = last.date
      self.last_clothing_log_id = last.id
    else
      self.last_worn = self.last_clothing_log_id = nil
    end
    self
  end

  def previous_by_id
    self.class.first(:conditions => ['id < ?', self.id], :order => 'id desc')
  end
  def next_by_id
    self.class.first(:conditions => ['id > ?', self.id], :order => 'id asc')
  end
end
