class CreateClothing < ActiveRecord::Migration
  def self.up
    create_table :clothing do |t|
      t.column :number, :integer
      t.column :label, :string
      t.column :colour, :string
      t.column :clothing_type, :string
      t.column :notes, :string
      t.column :labeled, :boolean, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :clothing
  end
end
