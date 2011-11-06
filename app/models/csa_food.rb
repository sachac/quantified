class CsaFood < ActiveRecord::Base
  belongs_to :food
  def self.remaining
    CsaFood.where('disposition = ""').sum(:quantity)
  end
  def self.next_delivery(date = nil)
    date ||= Date.today
    d = date.wday
    # 0 - 4 -   3
    # 1 - 3 -   4
    # 2 - 2 -   5
    # 3 - 1 -   6
    # 4 - 7 -   7
    # 5 - 6 -   1
    # 6 - 5 -   2
    date + (7 - (date.wday + 3) % 7).days
  end
end
