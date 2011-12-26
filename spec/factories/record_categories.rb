# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :record_category do
    name "MyString"
    parent_id 1
    category_type "MyString"
    data "MyText"
    lft 1
    rgt 1
  end
end
