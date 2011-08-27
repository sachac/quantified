class CreateClothingLogs < ActiveRecord::Migration
  def self.up
    create_table :clothing_logs do |t|
      t.column :clothing_id, :integer
      t.column :date, :datetime
    end
  end

  def self.down
    drop_table :clothing_logs
  end
end
