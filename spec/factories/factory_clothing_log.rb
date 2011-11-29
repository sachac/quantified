FactoryGirl.define do
  factory :clothing_log do
    user { @user }
    clothing
    date { Date.today }
    outfit_id 1
  end
end
