class AddSumToMeasurements < ActiveRecord::Migration
  def self.up
    add_column :measurements, :sum, :decimal
    Measurement.all.each do |m|
      m.sum = m.measurement_logs.sum('value')
    end
  end

  def self.down
    remove_column :measurements, :sum
  end
end
