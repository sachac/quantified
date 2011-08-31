class AddRatingToDecisions < ActiveRecord::Migration
  def self.up
    add_column :decisions, :rating, :integer
  end

  def self.down
    remove_column :decisions, :rating
  end
end
