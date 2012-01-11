class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.integer :user_id
      t.string :label
      t.string :expression
      t.string :period

      t.timestamps
    end
  end
end
