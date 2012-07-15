class Stuff < ActiveRecord::Base
  belongs_to :user
  delegate :url_helpers, :to => 'Rails.application.routes' 

  has_many :location_histories
  belongs_to :location, :class_name => 'Stuff'
  belongs_to :home_location, :class_name => 'Stuff'
  has_many :context_rules
  has_many :contexts, :through => :context_rules
  has_many :contained_stuff, :class_name => 'Stuff', :foreign_key => :location_id
  before_save :update_in_place

  scope :locations, where(:stuff_type => 'location')
  scope :out_of_place, where('location_id != home_location_id')
  def update_in_place
    self.in_place = (self.location and self.home_location and self.location == self.home_location)
    true
  end

  def distinct_locations
    self.location_histories.group('location_id')
  end

  def set_location(sym, val)
    if val.is_a? String
      loc = self.user.get_location(val)
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

  delegate :name, :to => :home_location, :prefix => true
  delegate :name, :to => :location, :prefix => true
  
  comma do
    id
    name
    long_name
    in_place
    location_id
    location_name
    home_location_id
    home_location_name
    price
    notes
  end
  
  def to_xml(options = {})
    super(options.update(:methods => [:home_location_name, :location_name]))
  end
  def to_json(options = {})
    super(options.update(:methods => [:home_location_name, :location_name]))
  end

  fires :new, :on => :create, :actor => :user

end
