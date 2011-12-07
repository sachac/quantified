class AddDurationToTapLogRecords < ActiveRecord::Migration
  def self.up
    add_column :tap_log_records, :duration, :integer
  end

  def self.down
    remove_column :tap_log_records, :duration
  end
end
