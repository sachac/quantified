class Location < ActiveRecord::Base
  belongs_to :user
  has_many :stuff
  has_many :location_histories
end
