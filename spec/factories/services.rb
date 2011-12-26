# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :service do
    user_id 1
    provider "MyString"
    uid "MyString"
    uname "MyString"
    uemail "MyString"
  end
end
