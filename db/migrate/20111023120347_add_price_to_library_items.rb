class AddPriceToLibraryItems < ActiveRecord::Migration
  def self.up
    add_column :library_items, :price, :decimal
  end

  def self.down
    remove_column :library_items, :price
  end
end
