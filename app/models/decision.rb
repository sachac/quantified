class Decision < ApplicationRecord
  belongs_to :user
  has_many :decision_logs
end
