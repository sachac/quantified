class ChangeSourceToSourceNameInRecord < ActiveRecord::Migration
  def up
    rename_column :records, :source, :source_name
  end

  def down
    rename_column :records, :source_name, :source
  end
end
