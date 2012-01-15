class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource
    resource.password = resource.password_confirmation = Passgen::generate(:lowercase => :only, :pronounceable => true)
    if resource.save
      add_flash :notice, "Thank you for signing up! Please check your e-mail for a message from sacha@quantifiedawesome.com containing your activation link. You can also log in right now through Google or Facebook."
      go_to new_user_session_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  protected
  def after_inactive_sign_up_path_for(resource)
    thanks_for_signing_up_path
  end        
end
