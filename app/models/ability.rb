class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role == 'admin'
      can :manage, :all
    elsif !user.id.blank?
      [Context, DecisionLog, Decision, Food, LibraryItem, LocationHistory, MeasurementLog, Measurement, Stuff, TimeRecord, TorontoLibrary, Memory, TapLogRecord, RecordCategory, Goal, ReceiptItem, ReceiptItemType, ReceiptItemCategory].each do |item|
        can :manage, item, user_id: user.id
        can :create, item
      end
      can :manage, GroceryList do |o|
        o.user_id == user.id || GroceryListUser.find_by(grocery_list_id: o.id, user_id: user.id)
      end
      can :create, GroceryList
      can :manage, GroceryListItem do |o|
        can? :manage, o.grocery_list
      end
      can :view_food, User, id: user.id
      can :manage_account, User, id: user.id
      can :delete, User, id: user.id
      can :view_tap_log_records, User, id: user.id
      can :view_time, User
      can :send_feedback, User do |o|
	!o.demo?
      end
    end
    [:view_contexts, :view_locations, :view_dashboard, :view_time, :view_tap_log_records].each do |sym|
      can sym, User do |u|
        u.demo? || u.id == user.id
      end
    end
    can :view, TapLogRecord do |o| o.user.demo? and o.public? end
    can :view_note, TapLogRecord do |o|
      (!o.private? and o.user.demo?) || (o.user_id == user.id)
    end
    can :view_site, User
  end
end
