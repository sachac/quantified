FactoryGirl.define do
  factory :library_item do
    user
    toronto_library { FactoryGirl.create(:toronto_library, user: user) }
  end
end
