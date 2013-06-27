# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :memory do
    user { @user }
    trait :public do
      access 'public'
    end
    trait :private do
      access 'private'
    end
  end
end
