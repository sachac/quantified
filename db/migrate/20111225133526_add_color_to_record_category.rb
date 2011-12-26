class AddColorToRecordCategory < ActiveRecord::Migration
  def change
    add_column :record_categories, :color, :string
  end
end
