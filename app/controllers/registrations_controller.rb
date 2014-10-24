class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(resource_params)
    if resource.save
      go_to new_user_session_path, notice: "Thank you for signing up! Please check your e-mail for a message from sacha@quantifiedawesome.com containing your activation link. You can also log in right now through Google or Facebook."
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  private
  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
