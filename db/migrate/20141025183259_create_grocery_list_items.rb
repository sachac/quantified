class CreateGroceryListItems < ActiveRecord::Migration
  def change
    create_table :grocery_list_items do |t|
      t.string :name
      t.integer :grocery_list_id
      t.string :quantity
      t.string :status

      t.timestamps
    end
  end
end
