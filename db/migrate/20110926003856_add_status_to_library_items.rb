class AddStatusToLibraryItems < ActiveRecord::Migration
  def self.up
    add_column :library_items, :status, :string
  end

  def self.down
    remove_column :library_items, :status
  end
end
