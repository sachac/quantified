# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :record do
    user
    source_name "MyString"
    source_id 1
    timestamp { Time.zone.now }
    record_category
    end_timestamp nil
  end
end
