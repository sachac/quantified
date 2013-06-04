class AdminController < ApplicationController
  def index
    authorize! :manage, User
    @signups = Signup.order('created_at DESC')
    @users = User.order('created_at DESC')
  end

  def become
    authorize! :manage, User
    sign_in User.find(params[:id]), :bypass => true
    redirect_to root_url
  end
  
  def activity
    authorize! :manage, User
    @totals = Hash.new 
    threshold = Time.zone.now.to_date - 30.days
    ['Clothing', 'ClothingLog', 'Record', 'Stuff'].each do |type_name|
      @totals[type_name] = Hash.new
      type = type_name.constantize
      @totals[type_name][:total] = type.count
      @totals[type_name][:not_me] = type.where('user_id != ?', 1).count
      if type_name == 'ClothingLog'
        @totals[type_name][:last_30] = type.where('date > ?', threshold).count
        @totals[type_name][:last_30_not_me] = type.where('user_id != ?', 1).where('date > ?', threshold).count
      else
        @totals[type_name][:last_30] = type.where('created_at > ?', threshold).count
        @totals[type_name][:last_30_not_me] = type.where('user_id != ?', 1).where('created_at > ?', threshold).count
      end
    end
  end
end
