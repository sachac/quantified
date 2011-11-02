class CreateMeasurementLogs < ActiveRecord::Migration
  def self.up
    create_table :measurement_logs do |t|
      t.integer :measurement_id
      t.datetime :datetime
      t.text :notes
      t.decimal :value

      t.timestamps
    end
  end

  def self.down
    drop_table :measurement_logs
  end
end
