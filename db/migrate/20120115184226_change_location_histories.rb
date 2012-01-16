class ChangeLocationHistories < ActiveRecord::Migration
  def up
    remove_column :location_histories, :location_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
