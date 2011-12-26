class CreateRecordCategories < ActiveRecord::Migration
  def self.up
    create_table :record_categories do |t|
      t.integer :user_id
      t.string :name
      t.integer :parent_id
      t.string :dotted_ids
      t.string :category_type
      t.text :data
      t.timestamps
    end
  end

  def self.down
    drop_table :record_categories
  end
end
