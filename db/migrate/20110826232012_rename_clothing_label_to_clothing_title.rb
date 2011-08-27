class RenameClothingLabelToClothingTitle < ActiveRecord::Migration
  def self.up
    rename_column :clothing, :label, :name
  end

  def self.down
    rename_column :clothing, :name, :label
  end
end
