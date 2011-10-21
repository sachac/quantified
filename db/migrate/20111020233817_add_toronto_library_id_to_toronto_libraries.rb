class AddTorontoLibraryIdToTorontoLibraries < ActiveRecord::Migration
  def self.up
    add_column :library_items, :toronto_library_id, :integer
  end

  def self.down
    remove_column :library_items, :toronto_library_id
  end
end
