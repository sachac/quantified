class AddAncestryToRecordCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :record_categories, :ancestry, :string
    add_index :record_categories, :ancestry
  end
end
