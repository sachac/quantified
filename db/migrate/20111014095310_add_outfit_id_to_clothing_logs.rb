class AddOutfitIdToClothingLogs < ActiveRecord::Migration
  def self.up
    add_column :clothing_logs, :outfit_id, :integer
  end

  def self.down
    remove_column :clothing_logs, :outfit_id
  end
end
