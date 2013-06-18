class AddIdToClothingMatches < ActiveRecord::Migration
  def change
    add_column :clothing_matches, :id, :primary_key
  end
end
