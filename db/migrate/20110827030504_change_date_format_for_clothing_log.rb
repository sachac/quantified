class ChangeDateFormatForClothingLog < ActiveRecord::Migration
  def self.up
    change_column :clothing_logs, :date, :date
  end

  def self.down
    change_column :clothing_logs, :date, :datetime
  end
end
