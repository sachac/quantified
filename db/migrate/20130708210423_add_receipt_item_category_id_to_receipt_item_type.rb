class AddReceiptItemCategoryIdToReceiptItemType < ActiveRecord::Migration
  def change
    add_column :receipt_item_types, :receipt_item_category_id, :integer
  end
end
