class LocationHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :location, :polymorphic => true
  belongs_to :stuff
end
