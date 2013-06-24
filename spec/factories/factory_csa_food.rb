FactoryGirl.define do
  factory :csa_food do
    food
    user { food.user }
  end
end
