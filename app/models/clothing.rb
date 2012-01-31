class Clothing < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable_on :tags
  has_many :clothing_logs, :dependent => :destroy
  has_many :clothing_matches, :foreign_key => :clothing_a_id, :dependent => :destroy
  has_attached_file :image, :styles => { :large => "400x400", :medium => "x90", :small => "x40" }, :default_url => '/images/clothing/:style/missing.jpg', :path => ':rails_root/public/f/clothing/:user_id/:hashed_path/:id/:style/:basename.:extension', :url => '/f/clothing/:user_id/:hashed_path/:id/:style/:basename.:extension'
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
    if self.color.blank? and self.image.file?
      begin 
        self.color = Clothing.guess_color(self.image) 
      rescue Exception 
        nil
      end
    end
    return unless self.color
    base = self.color.to_s.split(',')[0]
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

  def Clothing.guess_color(file, x = nil, y = nil)
    # http://www.jamievandyke.com/red-and-yellow-and
    if x =~ /^[0-9]+$/ and y =~ /^[0-9]+$/
      command = "convert #{file.path(:large)} -crop 1x1+#{x}+#{y} -format '%[pixel:u]' info:-"
    else
      command = "convert #{file.path(:large)} -scale 1x1\! -format '%[pixel:u]' info:-"
    end
    color = %x[#{command}]
    if color && $?.exitstatus == 0
      @red, @green, @blue = color[/rgb\((.*)\)/, 1].split(",").collect(&:to_i)
      "%2x%2x%2x" % [ @red, @green, @blue ]
    end
  end
  scope :active, where("(status IS NULL or status = 'active')")
end
