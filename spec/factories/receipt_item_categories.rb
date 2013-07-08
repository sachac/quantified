# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receipt_item_category do
    name "MyString"
    user
  end
end
