class RegistrationsController < Devise::RegistrationsController
  def new
    redirect_to new_user_session_path and return
    super
  end
  def create
    redirect_to new_user_session_path and return
  end
  private
  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
