class AddStatusToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :status, :string
  end
end
