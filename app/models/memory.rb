class Memory < ActiveRecord::Base
  acts_as_taggable_on :tags
  has_many :links
  belongs_to :user
end
