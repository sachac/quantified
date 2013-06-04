class Food < ActiveRecord::Base
  belongs_to :user
  has_many :csa_foods

  def self.get_food(account, name)
    food = account.foods.where('lower(name) = ?', name.downcase).first
    food ||= account.foods.where('lower(name) = ?', name.singularize.downcase).first
    food ||= account.foods.where('lower(name) = ?', name.pluralize.downcase).first
    food ||= Food.create(:user => account, :name => name)
    food
  end
  
  comma do
    id
    name
    notes
  end
end
