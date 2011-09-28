class AddHslToClothing < ActiveRecord::Migration
  def self.up
    add_column :clothing, :hue, :double
    add_column :clothing, :saturation, :double
    add_column :clothing, :brightness, :double
  end

  def self.down
    remove_column :clothing, :brightness
    remove_column :clothing, :saturation
    remove_column :clothing, :hue
  end
end
