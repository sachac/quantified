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
end
