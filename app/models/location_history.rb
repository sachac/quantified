class LocationHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :location, :class_name => 'Stuff'
  belongs_to :stuff
  
  delegate :name, :to => :stuff, :prefix => true
  delegate :name, :to => :location, :prefix => true
  
  comma do
    datetime
    stuff_id
    stuff_name
    location_id
    location_name
    notes
  end
  
  def to_xml(options = {})
    super(options.update(:methods => [:stuff_name, :location_name]))
  end
  def to_json(options = {})
    super(options.update(:methods => [:stuff_name, :location_name]))
  end

end
