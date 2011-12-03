class TapLogRecord < ActiveRecord::Base
  belongs_to :user
  validates :timestamp, :presence => true
  validates :catOne, :presence => true
  def time_category
    cat = nil
    case self.catOne
    when 'Discretionary'
      cat = 'D - ' + self.catTwo
    when 'Personal'
      cat = 'P - ' + self.catTwo
    when 'Unpaid work'
      cat = 'UW - ' + self.catTwo
    when 'Work'
      cat = 'A - Work'
    when 'Sleep'
      cat = 'A - Sleep'
    end
    cat
  end

  def to_s
    "#{self.timestamp}\t#{self.time_category}\t#{self.catOne}\t#{self.catTwo}\t#{self.catThree}"
  end
  def category_string
    [self.catOne, self.catTwo, self.catThree].compact.join ' > '
  end
end
