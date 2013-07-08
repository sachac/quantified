# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:receipt_item_name) { |n| "Receipt item #{n}" }
  factory :receipt_item do
    filename "image.jpg"
    source_id 1
    source_name "factory"
    store "Supermarket"
    date { Time.zone.now.to_date }
    name { FactoryGirl.generate(:receipt_item_name) }
    quantity "2"
    unit "pc"
    unit_price "2.50"
    total "5.00"
    notes ""
    user
    receipt_item_type nil
  end
end
