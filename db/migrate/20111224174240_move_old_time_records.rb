class MoveOldTimeRecords < ActiveRecord::Migration
  def up
    add_index :records, :timestamp
    add_index :record_categories, :name
    add_index :record_categories, :dotted_ids
    add_index :records, :record_category_id
  end

  def down
    remove_index :records, :timestamp
    remove_index :record_categories, :name
    remove_index :record_categories, :dotted_ids
    remove_index :records, :record_category_id
  end
end
