# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tap_log_record do
    timestamp Time.now
    catOne "MyString"
    user 
  end
end
