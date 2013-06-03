# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :context_rule do
    stuff
    location { FactoryGirl.create(:stuff, stuff_type: 'location') }
    context
  end
end
