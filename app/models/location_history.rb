class LocationHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :location, :class_name => 'Stuff'
  belongs_to :stuff
end
