class CreateReceiptItemCategories < ActiveRecord::Migration
  def change
    create_table :receipt_item_categories do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end
end
