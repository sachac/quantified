class AddNotesToLibraryItems < ActiveRecord::Migration
  def self.up
    add_column :library_items, :notes, :text
  end

  def self.down
    remove_column :library_items, :notes
  end
end
