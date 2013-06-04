class CsaFood < ActiveRecord::Base
  belongs_to :user
  belongs_to :food
  
  def self.next_delivery(date = nil)
    date ||= Time.zone.now.to_date
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
    past = account.csa_foods.where(:food_id => food.id, :date_received => options[:date_received] || Time.zone.today).first
    if past
      past.update_attributes(:quantity => past.quantity + options[:quantity])
    else
      account.csa_foods.create(:quantity => options[:quantity], :food => food, :unit => options[:unit], :date_received => options[:date_received])
    end
  end
  
  delegate :name, :to => :food

  comma do
    id
    date_received
    food_id
    name
    quantity
    unit
    disposition
    notes
  end
  
  def to_xml(options = {})
    super(options.update(:methods => :name))
  end
  def to_json(options = {})
    super(options.update(:methods => :name))
  end
  fires :new, :on => :create, :actor => :user, :secondary_subject => :food
  fires :update, :on => :update, :actor => :user, :secondary_subject => :food

end
