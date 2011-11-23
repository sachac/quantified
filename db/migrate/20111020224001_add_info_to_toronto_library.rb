class AddInfoToTorontoLibrary < ActiveRecord::Migration
  def self.up
    create_table :toronto_libraries do |t|
      t.timestamps
    end
    add_column :toronto_libraries, :name, :string
    add_column :toronto_libraries, :card, :string
    add_column :toronto_libraries, :pin, :string
    add_column :toronto_libraries, :last_checked, :date
    add_column :toronto_libraries, :pickup_count, :integer
    add_column :toronto_libraries, :library_item_count, :integer
  end

  def self.down
    drop_table :toronto_libraries
  end
end
