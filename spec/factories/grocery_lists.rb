FactoryGirl.define do
  factory :grocery_list_item do
    name "MyString"
    grocery_list :grocery_list
    quantity "MyString"
    status "MyString"
  end
  factory :grocery_list do
    user :user
    name "MyString"
  end

end
