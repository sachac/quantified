class AddDetailsToLibraryItems < ActiveRecord::Migration
  def change
    add_column :library_items, :details, :string
  end
end
