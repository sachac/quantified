FactoryGirl.define do 
  factory :measurement_log do
    measurement { FactoryGirl.create(:measurement) }
  end
end
