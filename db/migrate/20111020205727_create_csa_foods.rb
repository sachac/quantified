class CreateCsaFoods < ActiveRecord::Migration
  def self.up
    create_table :csa_foods do |t|
      t.integer :food_id
      t.integer :quantity
      t.string :unit
      t.string :date_received
      t.string :disposition
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :csa_foods
  end
end
