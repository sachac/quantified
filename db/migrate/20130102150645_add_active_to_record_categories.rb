class AddActiveToRecordCategories < ActiveRecord::Migration
  def change
    add_column :record_categories, :active, :boolean, :default => true
    RecordCategory.update_all 'active=true'
    change_column :record_categories, :active, :boolean, :null => false
  end
end
