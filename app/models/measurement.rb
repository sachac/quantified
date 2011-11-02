class Measurement < ActiveRecord::Base
  acts_as_taggable_on :tags
  has_many :measurement_logs
end
