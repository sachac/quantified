class CreateLocationHistories < ActiveRecord::Migration
  def self.up
    create_table :location_histories do |t|
      t.integer :stuff_id
      t.integer :location_id
      t.string :location_type
      t.datetime :datetime
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :location_histories
  end
end
