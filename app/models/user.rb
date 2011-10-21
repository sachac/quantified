class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  before_save :update_memento_mori 
  
  def update_memento_mori
    if birthdate_changed? or life_expectancy_in_years_changed? then
      self.projected_end = birthdate + life_expectancy_in_years.to_i.years
    end
  end

  def memento_mori
    if self.projected_end then
      days = (self.projected_end - Date.today)
      { :days => days.to_i, :months => (days * 1.day / 1.month).to_i, :years => (days * 1.day / 1.year).to_i, :weeks => (days * 1.day / 1.week).to_i }
    end
  end
end
