class LocationHistory < ActiveRecord::Base
  belongs_to :location, :polymorphic => true
  belongs_to :stuff
end
