class GroceryListUser < ActiveRecord::Base
  belongs_to :grocery_list
  belongs_to :user
end
