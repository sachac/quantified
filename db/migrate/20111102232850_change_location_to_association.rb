class ChangeLocationToAssociation < ActiveRecord::Migration
  def self.up
    remove_column :stuff, :location
    add_column :stuff, :location_id, :integer
    add_column :stuff, :location_type, :string
    add_index :stuff, :location_id
    add_index :stuff, [:name, :location_id]
  end

  def self.down
    add_column :stuff, :location, :string
  end
end
