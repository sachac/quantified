class CreateDecisionLogs < ActiveRecord::Migration
  def self.up
    create_table :decision_logs do |t|
      t.column :notes, :text
      t.column :notes_html, :text
      t.column :date, :date
      t.column :status, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :decision_logs
  end
end
