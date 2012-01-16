class CreateContextRules < ActiveRecord::Migration
  def change
    create_table :context_rules do |t|
      t.integer :stuff_id
      t.integer :location_id
      t.integer :context_id
      t.timestamps
    end
  end
end
