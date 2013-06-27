class CsaFood < ActiveRecord::Base
  belongs_to :user
  belongs_to :food
  def self.log(account, options)
    if options[:food].is_a? Food
      food = options[:food]
    else
      food = Food.get_food(account, options[:food])
    end
    past = account.csa_foods.where(:food_id => food.id, :date_received => options[:date_received] || Time.zone.today).first
    if past
      past.update_attributes(:quantity => past.quantity + options[:quantity])
      rec = past
    else
      rec = account.csa_foods.create(:quantity => options[:quantity], :food => food, :unit => options[:unit], :date_received => options[:date_received])
    end
    rec
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
