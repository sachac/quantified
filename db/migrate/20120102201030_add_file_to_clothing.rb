class AddFileToClothing < ActiveRecord::Migration
  def change
    add_column :clothing, :image_file_name, :string
    add_column :clothing, :image_file_size, :integer
    add_column :clothing, :image_content_type, :string
    add_column :clothing, :image_updated_at, :datetime
  end
end
