FactoryGirl.define do
  sequence(:goal_label) do |n| "Goal #{n}" end
  factory :goal do
    user
    label { FactoryGirl.generate(:goal_label) }
    trait :today do period "today" end
    trait :daily do period "daily" end
    trait :weekly do period "weekly" end
    trait :monthly do period "monthly" end
  end
end
