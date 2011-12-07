class AddInfoToTapLogRecords < ActiveRecord::Migration
  def self.up
    add_column :tap_log_records, :end_timestamp, :datetime
    add_column :tap_log_records, :entry_type, :string
    add_index :tap_log_records, :timestamp
    add_index :tap_log_records, [:catOne, :catTwo, :catThree]
    add_index :tap_log_records, :end_timestamp
  end

  def self.down
    remove_column :tap_log_records, :entry_type
    remove_column :tap_log_records, :end_timestamp
    remove_index :tap_log_records, :timestamp
    remove_index :tap_log_records, [:catOne, :catTwo, :catThree]
    remove_index :tap_log_records, :end_timestamp
  end
end
