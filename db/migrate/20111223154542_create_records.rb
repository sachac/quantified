class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :user_id
      t.string :source
      t.integer :source_id
      t.datetime :timestamp
      t.integer :record_category_id
      t.text :data
      t.datetime :end_timestamp
      t.integer :duration

      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
