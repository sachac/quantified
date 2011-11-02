class AddPagesToLibraryItems < ActiveRecord::Migration
  def self.up
    add_column :library_items, :pages, :integer
  end

  def self.down
    remove_column :library_items, :pages
  end
end
