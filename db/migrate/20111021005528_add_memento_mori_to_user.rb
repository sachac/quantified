class AddMementoMoriToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :birthdate, :date
    add_column :users, :life_expectancy_in_years, :integer
    add_column :users, :projected_end, :date
  end

  def self.down
    remove_column :users, :projected_end
    remove_column :users, :life_expectancy_in_years
    remove_column :users, :birthdate
  end
end
