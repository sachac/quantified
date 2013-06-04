class ChangeDateReceivedToDate < ActiveRecord::Migration
  def self.up
    add_column :csa_foods, :date_temp, :date
    CsaFood.reset_column_information
    CsaFood.all.each do |c|
      c.date_temp = Time.zone.parse(c.date_received)
      c.save!
    end
    remove_column :csa_foods, :date_received
    rename_column :csa_foods, :date_temp, :date_received
  end

  def self.down
    change_column :csa_foods, :date_received, :string
  end
end
