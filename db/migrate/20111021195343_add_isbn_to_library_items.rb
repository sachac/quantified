class AddIsbnToLibraryItems < ActiveRecord::Migration
  def self.up
    add_column :library_items, :isbn, :string
  end

  def self.down
    remove_column :library_items, :isbn
  end
end
