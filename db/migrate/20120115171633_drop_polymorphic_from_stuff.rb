class DropPolymorphicFromStuff < ActiveRecord::Migration
  def up
    remove_column :stuff, :home_location_type
    remove_column :stuff, :location_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
