class AddPrivateToLibraryItems < ActiveRecord::Migration
  def self.up
    add_column :library_items, :private, :boolean
  end

  def self.down
    remove_column :library_items, :private
  end
end
