class CreateMeasurements < ActiveRecord::Migration
  def self.up
    create_table :measurements do |t|
      t.string :name
      t.text :notes
      t.string :unit
      t.decimal :average
      t.decimal :max
      t.decimal :min

      t.timestamps
    end
  end

  def self.down
    drop_table :measurements
  end
end
