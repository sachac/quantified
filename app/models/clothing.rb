class Clothing < ApplicationRecord
  belongs_to :user
  acts_as_taggable_on :tags
  has_many :clothing_logs, :dependent => :destroy
  has_many :clothing_matches, :foreign_key => :clothing_a_id, :dependent => :destroy


  # has_attached_file :image, :styles => { :large => "400x400", :medium => "x90", :small => "x40" }, :default_url => '/images/clothing/:style/missing.jpg', :path => ':rails_root/public/f/clothing/:user_id/:hashed_path/:id/:style/:basename.:extension', :url => '/f/clothing/:user_id/:hashed_path/:id/:style/:basename.:extension'
  # validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
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
      self.color = Clothing.guess_color(self.image.path(:large)) 
    end
    return unless self.color
    base = self.color.to_s.split(',')[0]
    unless base.nil? then
      Color::RGB.from_html(base)
    end
  end

  def add_color(color_to_add)
    if self.color.blank? or color_to_add.blank?
      self.color = color_to_add
    else
      self.color = self.color + "," + color_to_add
    end
  end
  
  def delete_color(color_to_remove)
    colors = (self.color || '').split(',')
    result = colors.delete(color_to_remove)
    self.color = colors.join(',')
    result
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
    self.user.clothing.where('id < ?', self.id).order('id desc').first
  end
  def next_by_id
    self.user.clothing.where('id > ?', self.id).order('id asc').first
  end

  def Clothing.guess_color(filepath, x = nil, y = nil)
    if x =~ /^[0-9]+$/ and y =~ /^[0-9]+$/
      command = "convert #{filepath.to_s.shellescape} -crop 1x1+#{x}+#{y} -format '%[fx:255*r],%[fx:255*g],%[fx:255*b]' info:- 2>&1"
    else
      command = "convert #{filepath.to_s.shellescape} -scale 1x1\! -format '%[fx:255*r],%[fx:255*g],%[fx:255*b]' info:- 2>&1"
    end
    color = %x[#{command}]
    if color && $?.exitstatus == 0
      @red, @green, @blue = color.split(",").collect(&:to_i)
      "%02x%02x%02x" % [ @red, @green, @blue ]
    end
  end
  scope :active, -> { where("(status IS NULL or status = 'active')") }
  
  def image_url
    self.image.url
  end
  def to_xml(options = {})
    super(options.update(:methods => [:image_url]))
  end
  
  comma do
    id
    name
    clothing_type
    status
    color 
    last_worn
    clothing_logs_count
    cost
    notes
  end

  fires :new, :on => :create, :actor => :user

end
