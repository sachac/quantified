class AddDatesToLibraryItem < ActiveRecord::Migration
  def self.up
    add_column :library_items, :checkout_date, :date
    add_column :library_items, :return_date, :date
    add_column :library_items, :read_date, :date
  end

  def self.down
    remove_column :library_items, :read_date
    remove_column :library_items, :return_date
    remove_column :library_items, :checkout_date
  end
end
