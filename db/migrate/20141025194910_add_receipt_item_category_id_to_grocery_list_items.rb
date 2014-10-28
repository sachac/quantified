class AddReceiptItemCategoryIdToGroceryListItems < ActiveRecord::Migration
  def change
    add_column :grocery_list_items, :receipt_item_category_id, :integer
  end
end
