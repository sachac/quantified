class AddDecisionIdToDecisionLogs < ActiveRecord::Migration
  def self.up
    add_column :decision_logs, :decision_id, :integer
  end

  def self.down
    remove_column :decision_logs, :decision_id
  end
end
