class ChangePrivateToPublic < ActiveRecord::Migration
  def self.up
    rename_column :library_items, :private, :public
    LibraryItem.update_all('public = not public')
  end

  def self.down
    rename_column :library_items, :public, :private
    LibraryItem.update_all('private = not private')
  end
end
