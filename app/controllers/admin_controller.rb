class AdminController < ApplicationController
  def index
    authorize! :manage, User
    @signups = Signup.order('created_at DESC')
  end

  def invite_user
    User.invite! :email => params[:email]
    go_to admin_path, :notice => I18n.t('user.invited', 'email' => params[:email])
  end
end
