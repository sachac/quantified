FactoryGirl.define do 
  factory :measurement do
    user { FactoryGirl.create(:user) }
  end
end
