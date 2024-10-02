class GroceryListItem < ApplicationRecord
  belongs_to :grocery_list
  belongs_to :receipt_item_category
  before_validation :guess_category
  validates :grocery_list, presence: true
  validates :name, presence: true
  def guess_category
    # Try to pick a category base on the receipt item friendly name
    unless self.receipt_item_category
      if self.grocery_list and self.grocery_list.user
        type = self.grocery_list.user.receipt_item_types.find_by(friendly_name: self.name)
        if type
          self.receipt_item_category = type.receipt_item_category
        end
      end
    end
  end
  def category
    self.receipt_item_category.name if self.receipt_item_category
  end
  def category=(value)
    if self.grocery_list and self.grocery_list.user
      self.receipt_item_category = self.grocery_list.user.receipt_item_categories.find_by_name(value)
      if value and !self.receipt_item_category
        self.receipt_item_category = self.grocery_list.user.receipt_item_categories.new
        self.receipt_item_category.name = value
        self.receipt_item_category.save!
      end
    end
  end

  def price_history
    if self.grocery_list and self.grocery_list.user
      ReceiptItem.joins(:receipt_item_type).where('receipt_items.user_id=? AND receipt_item_types.friendly_name=?', self.grocery_list.user_id, self.name)
    end
  end
end
