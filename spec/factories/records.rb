# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :record do
    source_name "MyString"
    source_id 1
    timestamp { Time.zone.now }
    record_category
    user { record_category ? record_category.user : FactoryGirl.create(:confirmed_user) }
    end_timestamp nil
  end
end
