class Location < ActiveRecord::Base
  has_many :stuff
  has_many :location_histories
end
