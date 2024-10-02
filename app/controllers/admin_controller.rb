class AdminController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    authorize! :manage, User
    @users = User.order('created_at DESC')
  end

  def become
    authorize! :manage, User
    sign_in User.find(params[:id]), :bypass => true
    redirect_to root_url
  end
end
