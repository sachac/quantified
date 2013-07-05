class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, :all
    elsif !user.id.blank?
      [Clothing, ClothingLog, Context, ClothingMatch, CsaFood, DecisionLog, Decision, Food, LibraryItem, LocationHistory, MeasurementLog, Measurement, Stuff, TimeRecord, TorontoLibrary, Memory, TapLogRecord, RecordCategory, Goal].each do |item|
        can :manage, item, user_id: user.id
        can :create, item
      end
      can :view_food, User, id: user.id
      can :manage_account, User, id: user.id
      can :delete, User, id: user.id
      can :view_tap_log_records, User, id: user.id
      can :view_time, User
      can :send_feedback, User
    end
    can :view, LibraryItem do |o| o.public? and o.user.demo? end
    can :view, Memory do |o| o.public? and o.user.demo? end
    [:view_contexts, :view_locations, :view_dashboard, :view_clothing, :view_clothing_logs, :view_time, :view_library_items, :view_memories, :view_tap_log_records].each do |sym|
      can sym, User do |u|
        u.demo? || u.id == user.id
      end
    end
    can :view, Clothing do |o| o.user.demo? end
    can :view, TapLogRecord do |o| o.user.demo? and o.public? end
    can :view_note, TapLogRecord do |o|
      (!o.private? and o.user.demo?) || (o.user_id == user.id)
    end
    can :view_site, User
    can :send_feedback, User
  end
end
