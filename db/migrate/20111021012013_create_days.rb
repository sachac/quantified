class CreateDays < ActiveRecord::Migration
  def self.up
    create_table :days do |t|
      t.date :date
      t.integer :temperature
      t.string :clothing_temperature
      t.integer :library_checked_out
      t.integer :library_pickup
      t.integer :library_transit

      t.timestamps
    end
  end

  def self.down
    drop_table :days
  end
end
