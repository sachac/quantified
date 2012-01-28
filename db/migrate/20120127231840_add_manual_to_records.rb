class AddManualToRecords < ActiveRecord::Migration
  def change
    add_column :records, :manual, :boolean, :default => false
  end
end
