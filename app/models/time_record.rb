class TimeRecord < ApplicationRecord
  belongs_to :user
  def starts_at
    self.start_time
  end
  def ends_at
    self.end_time
  end
  def category
    if name.match /^A - Work/ 
      'Work'
    elsif name.match /^A - Sleep/ 
      'Sleep'
    elsif name.match /^D - / 
      'Discretionary'
    elsif name.match /^UW - / 
      'Unpaid work'
    elsif name.match /^P - / 
      'Personal care'
    end
  end
end
