class AddDefaultOutfitId < ActiveRecord::Migration
  def self.up
    ClothingLog.update_all('outfit_id = 1', 'outfit_id IS NULL')
    change_column :clothing_logs, :outfit_id, :integer, :default => 1
  end

  def self.down
  end
end
