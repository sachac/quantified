FactoryGirl.define do
  sequence(:username) { |n| "test#{n}" }
  factory :user do
    username
    email { "#{username}@example.org" }
    role 'user'
    password { Forgery(:basic).password }
    password_confirmation { password }
  end
  factory :confirmed_user, :parent => :user do |f|
    f.after(:create) { |user| user.confirm! }
  end
  factory :demo_user, :parent => :confirmed_user do
    role 'demo'
  end
  factory :admin, :parent => :confirmed_user do 
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
