class AddLastWornAndCountToClothing < ActiveRecord::Migration
  def self.up
    add_column :clothing, :last_worn, :date
    add_column :clothing, :clothing_logs_count, :integer, :default => 0
    add_column :clothing, :last_clothing_log_id, :integer
    # Set them
    Clothing.reset_column_information
    Clothing.all.each do |c|
      last = ClothingLog.where('clothing_id=?', c.id).order('date DESC').limit(1).first
      if last then
        c.last_clothing_log_id = last.id
        c.last_worn = last.date
        c.save
      end
      Clothing.reset_counters c.id, :clothing_logs
    end
  end

  def self.down
    remove_column :clothing, :count
    remove_column :clothing, :last_worn
    remove_column :clothing, :last_clothing_log_id
  end
end
