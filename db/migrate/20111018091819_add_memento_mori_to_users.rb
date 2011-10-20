class AddMementoMoriToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birthdate, :date
    add_column :users, :life_expectancy, :float
  end

  def self.down
    remove_column :users, :life_expectancy
    remove_column :users, :birthdate
  end
end
