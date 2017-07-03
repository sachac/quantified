# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :record_category do
    sequence :name do |n| "Category#{n}Name" end
    user
    category_type "activity"
    trait :activity do category_type "activity" end
    trait :list do category_type "list" end
    trait :record do category_type "record" end
  end
end
