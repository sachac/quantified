# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receipt_item_type do
    receipt_name "MyString"
    friendly_name "MyString"
    user
  end
end
