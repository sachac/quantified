class CreateFoods < ActiveRecord::Migration
  def self.up
    create_table :foods do |t|
      t.string :name
      t.string :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :foods
  end
end
