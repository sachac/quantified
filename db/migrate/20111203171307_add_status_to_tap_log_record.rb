class AddStatusToTapLogRecord < ActiveRecord::Migration
  def self.up
    add_column :tap_log_records, :status, :string
  end

  def self.down
    remove_column :tap_log_records, :status
  end
end
