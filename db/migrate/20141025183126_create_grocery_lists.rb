class CreateGroceryLists < ActiveRecord::Migration
  def change
    create_table :grocery_lists do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
