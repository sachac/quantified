class AddStuffTypeAndMergeLocations < ActiveRecord::Migration
  def up
    # Merge stuff and locations
    unless column_exists? :stuff, :stuff_type
      add_column :stuff, :stuff_type, :string, :default => 'stuff'
    end
    # Copy locations into stuff
    Location.all.each do |l|
      new_location = Stuff.create(:stuff_type => 'location', :name => l.name, :notes => l.notes, :user => l.user)
      # Move everything associated with that location
      LocationHistory.where(:location_id => l.id, :location_type => 'Location').update_all({:location_id => new_location.id, :location_type => 'Stuff'})
      Stuff.where(:location_id => l.id, :location_type => 'Location').update_all({:location_id => new_location.id, :location_type => 'Stuff'})
      Stuff.where(:home_location_id => l.id, :home_location_type => 'Location').update_all({:home_location_id => new_location.id, :home_location_type => 'Stuff
'})
      l.destroy
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
