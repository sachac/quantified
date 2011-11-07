class Measurement < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable_on :tags
  has_many :measurement_logs
end
