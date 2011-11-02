class CreateStuff < ActiveRecord::Migration
  def self.up
    create_table :stuff do |t|
      t.string :name
      t.string :status
      t.string :location
      t.decimal :price
      t.date :purchase_date
      t.text :notes
      t.string :long_name
      t.timestamps
    end
    add_index :stuff, :name
  end

  def self.down
    drop_table :stuff
  end
end
