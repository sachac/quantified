class ServicesController < ApplicationController
  skip_authorization_check :only => [:create]
  def index
    authorize! :manage_account, current_account
    @services = current_account.services.all
  end
  
  def create
    omniauth = request.env['omniauth.auth']
    service_route = params[:service] || 'no service (invalid callback)'
    unless omniauth and params[:service]
      flash[:error] = 'Error while authenticating via ' + service_route.capitalize + '.'
      redirect_to new_user_session_path and return
    end
    case service_route
    when 'facebook'
      email = omniauth['extra']['raw_info']['email']
      name = omniauth['extra']['raw_info']['name']
      uid = omniauth['extra']['raw_info']['id']
      provider = omniauth['provider']
    when 'twitter'
      email = ''    # Twitter API never returns the email address
      name = omniauth['user_info']['name']
      uid = omniauth['uid']
      provider = omniauth['provider']
    when 'google'
      email = omniauth['info']['email']
      name = omniauth['info']['name']
      provider = omniauth['provider']
      uid = omniauth['uid']
    else
      render :text => omniauth.to_yaml
      return
    end
    if uid.blank? or provider.blank?
      flash[:error] =  service_route.capitalize + ' returned invalid data for the user id.'
      redirect_to new_user_session_path and return
    end
    auth = Service.find_by_provider_and_uid(provider, uid)
    if user_signed_in?
      if !auth
        current_account.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email)
        flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account.'
        redirect_to services_path and return
      else
        flash[:notice] = service_route.capitalize + ' is already linked to your account.'
        redirect_to services_path and return
      end  
    end
    
    if auth
      flash[:notice] = 'Signed in successfully via ' + provider.capitalize + '.'
      sign_in_and_redirect(:user, auth.user)
    else
      # check if this user is already registered with this email address; get out if no email has been provided
      if !email.blank?
        # search for a user with this email address
        existing_user = User.find_by_email(email)
        if existing_user
          # map this new login method via a service provider to an existing account if the email address is the same
          existing_user.services.create(:provider => provider, :uid => uid, :uname => name, :uemail => email)
          flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account ' + existing_user.email + '. Signed in successfully!'
          sign_in_and_redirect(:user, existing_user)
        elsif Devise.mappings[:user].registerable?
          # let's create a new user: register this user and add this authentication method for this user
          name = name[0, 39] if name.length > 39             # otherwise our user validation will hit us
          # new user, set email, a random password and take the name from the authentication service
          user = User.new :email => email, :password => SecureRandom.hex(10), :fullname => name, :username => name
          # add this authentication service to our new user
          user.services.build(:provider => provider, :uid => uid, :uname => name, :uemail => email)
          
          # do not send confirmation email, we directly save and confirm the new record
          user.skip_confirmation!
          user.save!
          user.confirm!
          
          # flash and sign in
          flash[:notice] = 'Your account on Quantified Awesome has been created via ' + provider.capitalize + '. In your profile you can change your personal information and add a local password.'
          sign_in_and_redirect(:user, user)
        else 
          # Not accepting new users yet
          signup = Signup.find_by_email(email)
          if signup
            flash[:notice] = "Thanks! Still not ready to take on new users, but you're still on the list!"
            redirect_to root_path and return
          else
            signup = Signup.create(:email => email)
            flash[:notice] = "Thanks for your interest! When Quantified Awesome is ready for new users, I'll get in touch!"
            redirect_to root_path and return
          end
        end
      else
        flash[:error] =  service_route.capitalize + ' can not be used to sign-up on Quantified Awesome as no valid email address has been provided. Please use another authentication provider or use local sign-up. If you already have an account, please sign-in and add ' + service_route.capitalize + ' from your profile.'
        redirect_to new_user_session_path and return
      end
    end
  end
  
  def destroy
    authorize! :manage_account, current_account
    # remove an authentication service linked to the current user
    @service = current_account.services.find(params[:id])
    @service.destroy
    
    redirect_to services_path
  end
end
