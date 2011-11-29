# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :memory do
    user { @user }
  end
end
