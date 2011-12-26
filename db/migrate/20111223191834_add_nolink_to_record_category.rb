class AddNolinkToRecordCategory < ActiveRecord::Migration
  def self.up
    add_column :record_categories, :full_name, :string
  end

  def self.down
    remove_column :record_categories, :full_name
  end
end
