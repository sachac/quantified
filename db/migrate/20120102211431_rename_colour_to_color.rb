class RenameColourToColor < ActiveRecord::Migration
  def up
    rename_column :clothing, :colour, :color
  end

  def down
    rename_column :clothing, :color, :colour
  end
end
