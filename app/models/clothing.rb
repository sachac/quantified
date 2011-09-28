class Clothing < ActiveRecord::Base
  acts_as_taggable_on :tags
  has_many :clothing_logs
  before_save :update_hsl
  def autocomplete_view
    "#{self.number} - #{self.name}"
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
    base = self.colour.split(',')[0]
    unless base.nil? then
      Color::RGB.from_html(base)
    end
  end
end
