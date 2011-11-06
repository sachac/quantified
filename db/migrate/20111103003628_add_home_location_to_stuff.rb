class AddHomeLocationToStuff < ActiveRecord::Migration
  def self.up
    add_column :stuff, :home_location_id, :integer
    add_column :stuff, :home_location_type, :string
  end

  def self.down
    remove_column :stuff, :home_location_type
    remove_column :stuff, :home_location_id
  end
end
