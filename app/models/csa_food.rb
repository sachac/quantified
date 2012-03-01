class CsaFood < ActiveRecord::Base
  belongs_to :user
  belongs_to :food
  
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

  def self.log(account, options)
    if options[:food].is_a? Food
      food = options[:food]
    else
      food = Food.get_food(account, options[:food])
    end
    past = account.csa_foods.where(:food_id => food.id, :date_received => options[:date_received] || Date.today).first
    if past
      past.update_attributes(:quantity => past.quantity + options[:quantity])
    else
      account.csa_foods.create(:quantity => options[:quantity], :food => food, :unit => options[:unit], :date_received => options[:date_received])
    end
  end
end
