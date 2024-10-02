class GroceryList < ApplicationRecord
  belongs_to :user
  has_many :grocery_list_items
  has_many :grocery_list_users
  validates :name, presence: true

  def self.lists_for(user)
    return GroceryList.joins('LEFT JOIN grocery_list_users ON grocery_lists.id=grocery_list_users.grocery_list_id')
            .where('grocery_lists.user_id=? OR grocery_list_users.user_id=?', user.id, user.id)
  end
end
