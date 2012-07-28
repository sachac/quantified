class AddDateToMemories < ActiveRecord::Migration
  def change
    add_column :memories, :date_entry, :string
    add_column :memories, :sort_time, :datetime
  end
end
