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
      can :manage_account, User, :user_id => user.id
      can :view_library_items, User
      can :view_contexts, User
      can :view_time, User
    else # Not logged in
      can :view, LibraryItem, :public => true
      can :view_contexts, User
    end
    can :view_dashboard, User
    can :view_clothing, User
    can :view_time, User
    can :view_library_items, User
    can :view, Clothing
  end
end
