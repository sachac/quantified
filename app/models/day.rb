class Day < ActiveRecord::Base
  belongs_to :user
  def self.yesterday
    y = Day.find_or_create_by_date(Time.zone.today.yesterday)
    y.save if y.new_record?
    y
  end
  def self.today
    y = Day.find_or_create_by_date(Time.zone.today)
    y.save if y.new_record?
    y
  end
end
