class DecisionLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :decision
end
