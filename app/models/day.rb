class Day < ActiveRecord::Base
  belongs_to :user
  def self.today(user)
    y = user.days.find_or_create_by(date: Time.zone.today)
    y.save if y.new_record?
    y
  end
  def self.yesterday(user)
    y = user.days.find_or_create_by(date: Time.zone.today.yesterday)
    y.save if y.new_record?
    y
  end
end
