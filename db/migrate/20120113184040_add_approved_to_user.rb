class AddApprovedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :approved, :boolean, :default => false, :null => false
  end
  def self.down
    remove_column :users, :approved
  end
end
