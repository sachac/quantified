class CreateTimeRecords < ActiveRecord::Migration
  def self.up
    create_table :time_records do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :time_records
  end
end
