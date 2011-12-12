class AddSourceToTapLogRecords < ActiveRecord::Migration
  def self.up
    add_column :tap_log_records, :source, :string
    TapLogRecord.reset_column_information
    TapLogRecord.update_all("source='tap_log'")
  end

  def self.down
    remove_column :tap_log_records, :source
  end
end
