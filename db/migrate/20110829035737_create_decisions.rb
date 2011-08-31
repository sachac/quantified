class CreateDecisions < ActiveRecord::Migration
  def self.up
    create_table :decisions do |t|
      t.column :name, :string
      t.column :date, :date
      t.column :notes, :text
      t.column :notes_html, :text
      t.column :status, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :decisions
  end
end
