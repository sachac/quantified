class Food < ActiveRecord::Base
  belongs_to :user
  has_many :csa_foods

  def self.get_food(account, name)
    food = account.foods.find_by_name(name)
    food ||= account.foods.find_by_name(name.singularize)
    food ||= account.foods.find_by_name(name.pluralize)
    unless food
      food = Food.create(:user => account, :name => name)
    end
    food
  end
  
  comma do
    id
    name
    notes
  end
end
