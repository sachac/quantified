# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :record do
    user
    source "MyString"
    source_id 1
    timestamp "2011-12-23 10:45:42"
    record_category_id 1
    end_timestamp "2011-12-23 10:45:42"
    duration 1
  end
end
