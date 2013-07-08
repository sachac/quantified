class CreateReceiptItemTypes < ActiveRecord::Migration
  def change
    create_table :receipt_item_types do |t|
      t.string :receipt_name
      t.string :friendly_name
      t.integer :user_id

      t.timestamps
    end
  end
end
