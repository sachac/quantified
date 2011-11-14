class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, :all
    elsif !user.id.blank?
      [Clothing, ClothingLog, ClothingMatch, CsaFood, Day, DecisionLog, Decision, Food, LibraryItem, LocationHistory, Location, MeasurementLog, Measurement, Stuff, TimeRecord, TorontoLibrary, Context].each do |item|
        can :manage, item, :user_id => user.id
        can :create, item
      end
    else # Not logged in
      can :read, LibraryItem, :public => true
    end
  end
end
