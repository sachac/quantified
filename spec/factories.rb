FactoryGirl.define do
  factory :user do
    username { Forgery(:internet).user_name }
    email { "#{username}@example.org" }
    role 'user'
    password { Forgery(:basic).password }
    password_confirmation { password }
  end
  factory :admin, :parent => :user do
    role 'admin'
  end
  factory :stuff do
    name { Forgery(:name).full_name + ' stuff' }
    status 'active'
    user
  end
  factory :location do
    name { Forgery(:name).full_name + ' location' }
    user
  end
  factory :location_history do
    stuff
    location
    datetime { Time.now }
    user
  end
end
