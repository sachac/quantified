class AddTimeAndRatingToMemories < ActiveRecord::Migration
  def self.up
    add_column :memories, :timestamp, :datetime
    add_column :memories, :rating, :integer
  end

  def self.down
    remove_column :memories, :rating
    remove_column :memories, :timestamp
  end
end
