class CreateGroceryListUsers < ActiveRecord::Migration
  def change
    create_table :grocery_list_users do |t|
      t.integer :grocery_list_id
      t.string :email
      t.integer :user_id
      t.string :status

      t.timestamps
    end
  end
end
