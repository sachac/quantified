FactoryGirl.define do
  sequence :username do |n| "test#{n}" end
  factory :user do |f| 
    f.after_create { |user| user.confirm! }
    f.username { Factory.next(:username) }
    f.email { "#{username}@example.org" }
    f.role 'user'
    f.password { Forgery(:basic).password }
    f.password_confirmation { password }
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
    name { Factory.next(:context_name) }
    user
  end
end
