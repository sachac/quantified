class GroceryListUser < ApplicationRecord
  belongs_to :grocery_list
  belongs_to :user
end
