class GroceryList < ActiveRecord::Base
  belongs_to :user
  has_many :grocery_list_items
  validates :name, presence: true
end
