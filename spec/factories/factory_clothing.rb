FactoryGirl.define do
  sequence :clothing_name do |n| "Clothing #{n}" end
  factory :clothing do
    user 
    name { FactoryGirl.generate(:clothing_name) }
    status "active"
  end
end
