class Decision < ActiveRecord::Base
  belongs_to :user
  has_many :decision_logs
end
