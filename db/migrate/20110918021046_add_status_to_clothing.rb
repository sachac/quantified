class AddStatusToClothing < ActiveRecord::Migration
  def self.up
    add_column :clothing, :status, :string
  end

  def self.down
    remove_column :clothing, :status
  end
end
