class AddCostToClothing < ActiveRecord::Migration
  def self.up
    add_column :clothing, :cost, :float
  end

  def self.down
    remove_column :clothing, :cost
  end
end
