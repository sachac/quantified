class CreateReceiptItems < ActiveRecord::Migration
  def change
    create_table :receipt_items do |t|
      t.integer :user_id
      t.string :filename
      t.string :source_id
      t.string :source_name
      t.string :store
      t.date :date
      t.string :name
      t.decimal :quantity, precision: 10, scale: 3
      t.string :unit
      t.decimal :unit_price, precision: 10, scale: 3
      t.decimal :total, precision: 10, scale: 2
      t.string :notes

      t.timestamps
    end
  end
end
