FactoryGirl.define do
  sequence :clothing_name do |n| "Clothing #{n}" end
  factory :clothing do
    user { @user }
    name { Factory.next(:clothing_name) }
    status "active"
  end
end
