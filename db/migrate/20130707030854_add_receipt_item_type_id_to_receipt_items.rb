class AddReceiptItemTypeIdToReceiptItems < ActiveRecord::Migration
  def change
    add_column :receipt_items, :receipt_item_type_id, :integer
  end
end
