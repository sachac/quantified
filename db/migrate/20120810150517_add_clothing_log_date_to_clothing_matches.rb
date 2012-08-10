class AddClothingLogDateToClothingMatches < ActiveRecord::Migration
  class ClothingMatch < ActiveRecord::Base
    belongs_to :clothing_log_a, :class_name => "ClothingLog"
  end
  class ClothingLog < ActiveRecord::Base
  end
  def change
    add_column :clothing_matches, :clothing_log_date, :date
    ClothingMatch.reset_column_information
    ClothingMatch.joins(:clothing_log_a).update_all('clothing_log_date = clothing_logs.date')
  end
end
