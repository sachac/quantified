class Day < ActiveRecord::Base
  def self.yesterday
    y = Day.find_or_create_by_date(Date.yesterday)
    y.save if y.new_record?
    y
  end
  def self.today
    y = Day.find_or_create_by_date(Date.today)
    y.save if y.new_record?
    y
  end
end
