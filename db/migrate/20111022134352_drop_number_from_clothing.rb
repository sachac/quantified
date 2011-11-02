class DropNumberFromClothing < ActiveRecord::Migration
  def self.up
    remove_column :clothing, :number
  end

  def self.down
    add_column :clothing, :number, :integer
  end
end
