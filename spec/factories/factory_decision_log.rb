FactoryGirl.define do
  factory :decision_log do
    decision
    user { decision.user }
  end
end
