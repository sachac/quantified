class CreateLibraryItems < ActiveRecord::Migration
  def self.up
    create_table :library_items do |t|
      t.column :library_id, :string
      t.column :dewey, :string
      t.column :title, :string
      t.column :author, :string
      t.column :due, :date
      t.column :rating, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :library_items
  end
end
