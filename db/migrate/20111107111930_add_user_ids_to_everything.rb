class AddUserIdsToEverything < ActiveRecord::Migration
  def self.up
    me = User.first
    if table_exists? :books then drop_table :books end
    [:clothing, :clothing_logs, :clothing_matches, :csa_foods, :days, :decision_logs, :decisions, :foods, :location_histories, :library_items, :locations, :measurement_logs, :measurements, :stuff, :time_records, :toronto_libraries].each do |sym|
      add_column sym, :user_id, :integer
      add_index sym, :user_id
      # Assume all the data is mine in the beginning
      sym.to_s.classify.constantize.update_all(['user_id=?', me.id])
    end
  end

  def self.down
    [:clothing, :clothing_logs, :clothing_matches, :csa_foods, :days, :decision_logs, :decisions, :foods, :location_histories, :library_items, :locations, :measurement_logs, :measurements, :stuff, :time_records, :toronto_libraries].each do |sym|
      remove_column sym, :user_id, :integer
    end
  end
end
