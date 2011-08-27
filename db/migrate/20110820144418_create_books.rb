class CreateBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |t|
      t.column :title, :string
      t.column :library_code, :string
      t.column :due_date, :date
      t.timestamps
    end
  end

  def self.down
    drop_table :books
  end
end
