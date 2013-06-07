# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :record_category do
    name "MyString"
    user
    category_type "activity"
  end
end
