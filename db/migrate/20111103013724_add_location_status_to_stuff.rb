class AddLocationStatusToStuff < ActiveRecord::Migration
  def self.up
    add_column :stuff, :in_place, :boolean
  end

  def self.down
    remove_column :stuff, :in_place
  end
end
