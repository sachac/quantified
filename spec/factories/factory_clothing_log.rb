FactoryGirl.define do
  factory :clothing_log do
    user 
    clothing { FactoryGirl.create(:clothing, user: user) }
    date { Time.zone.today }
    outfit_id 1
  end
end
