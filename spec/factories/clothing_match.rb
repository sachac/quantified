FactoryGirl.define do
  factory :clothing_match do
    user 
    clothing_a { FactoryGirl.create(:clothing, user: user) }
    clothing_b { FactoryGirl.create(:clothing, user: user) }
    clothing_log_a { FactoryGirl.create(:clothing_log, user: user, clothing: clothing_a, date: Time.zone.today) }
    clothing_log_b { FactoryGirl.create(:clothing_log, user: user, clothing: clothing_b, date: Time.zone.today) }
  end
end
