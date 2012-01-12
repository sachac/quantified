class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, :all
    elsif !user.id.blank?
      [Clothing, ClothingLog, ClothingMatch, CsaFood, Day, DecisionLog, Decision, Food, LibraryItem, LocationHistory, Location, MeasurementLog, Measurement, Stuff, TimeRecord, TorontoLibrary, Context, Memory, TapLogRecord, RecordCategory].each do |item|
        can :manage, item, :user_id => user.id
        can :create, item
      end
      can :manage_account, User, :id => user.id
      can :view_library_items, User
      can :view_contexts, User
      can :view_tap_log_records, User, :id => user.id
      can :view_time, User
      can :send_feedback, User
    else # Not logged in
      can :view, LibraryItem, :public => true
      can :view, Memory, :access => 'public'
      can :view_contexts, User
    end
    [:view_locations, :view_dashboard, :view_clothing, :view_time, :view_library_items, :view_memories, :view_tap_log_records].each do |sym|
      can sym, User do |u|
        u.id == 1 || u.id == user.id
      end
    end
    can :view, Clothing
    can :view, TapLogRecord
    can :view_note, TapLogRecord do |u|
      !u.private? || u.user_id = user.id
    end
    can :view_site, User
    can :send_feedback, User
  end
end
