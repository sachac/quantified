class Stuff < ActiveRecord::Base
  belongs_to :user
  delegate :url_helpers, :to => 'Rails.application.routes' 

  has_many :location_histories
  belongs_to :location, :polymorphic => true
  belongs_to :home_location, :polymorphic => true
  has_many :stuff, :through => :stuff, :foreign_key => :location_id
  before_save :update_in_place

  def update_in_place
    self.in_place = (self.location and self.home_location and self.location == self.home_location)
    true
  end

  def distinct_locations
    LocationHistory.where('stuff_id=?', self.id).group('location_id, location_type')
  end
  def self.get_location(val)
    if val.is_a? String
      if match = val.match(/^([0-9]+)-(Stuff|Location)/)
        id = match[1]
        model = match[2]
        Kernel.const_get(model).find(id)
      else  
        loc = Stuff.find(:first, :conditions => ['lower(name)=?', val.downcase.strip])
        loc ||= Location.find(:first, :conditions => ['lower(name)=?', val.downcase.strip])
        loc ||= Location.create(:name => val.strip)
      end
    else
      val
    end
  end

  def set_location(sym, val)
    if val.is_a? String
      loc = Stuff.get_location(val)
    else
      loc = val
    end
    send("#{sym}=", loc)
  end

  def hierarchy
    seen = []
    list = []
    loc = self.location
    while loc
      list << loc
      if loc.is_a? Stuff
        loc = loc.location
        loc = nil if seen.include? loc
      else
        loc = nil
      end
      seen << loc
    end
    list
  end

  def self.out_of_place
    Stuff.where('status="active" AND (location_id != home_location_id OR location_type != home_location_type)')
  end

end
