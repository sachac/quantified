class CreateTapLogRecords < ActiveRecord::Migration
  def self.up
    create_table :tap_log_records do |t|
      t.integer :user_id
      t.integer :tap_log_id
      t.datetime :timestamp
      t.string :catOne
      t.string :catTwo
      t.string :catThree
      t.decimal :number, :precision => 10, :scale => 2
      t.integer :rating
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :tap_log_records
  end
end
