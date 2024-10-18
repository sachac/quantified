FactoryGirl.define do
  sequence(:username) { |n| "test#{n}" }
  factory :user do
    username
    email { "#{username}@example.org" }
    role 'user'
    password { Forgery(:basic).password }
    password_confirmation { password }
    trait :admin do
      role 'admin'
    end
    trait(:demo) do
      role 'demo'
    end
  end
  factory :demo_user, :parent => :user do
    role 'demo'
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
  sequence :context_name do |n| "Context #{n}" end
  factory :context do
    name { FactoryGirl.generate(:context_name) }
    user
  end
end
