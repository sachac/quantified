class ServicesController < ApplicationController
  skip_authorization_check :only => [:create]
  protect_from_forgery :except => [:create]
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
    when 'google'
      email = omniauth['info']['email']
      name = omniauth['info']['name']
      provider = omniauth['provider']
      uid = omniauth['uid']
else
flash[:error] =  service_route.capitalize + ' cannot be used to sign up on Quantified Awesome. Please use another authentication provider, or create an account.'
      redirect_to new_user_session_path and return
    end
    
    if uid.blank? or provider.blank?
      flash[:error] =  service_route.capitalize + ' returned invalid data for the user id.'
      redirect_to new_user_session_path and return
    end
    auth = Service.find_by_provider_and_uid(provider, uid)
    if user_signed_in?
      if !auth
        s = current_account.services.new
        s.provider = provider
        s.uid = uid
        s.uname = name
        s.save!
        flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account.'
        redirect_to root_path and return
      else
        flash[:notice] = service_route.capitalize + ' is already linked to your account.'
        redirect_to root_path and return
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
          service = existing_user.services.build
          service.provider = provider
          service.uid = uid
          service.uname = name
          service.save
          flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account ' + existing_user.email + '. Signed in successfully!'
          sign_in_and_redirect(:user, existing_user)
        else
          # new user, set email, a random password and take the name from the authentication service
          # let's create a new user: register this user and add this authentication method for this user
          name = name[0, 39] if name.length > 39             # otherwise our user validation will hit us
          user = User.new
          user.email = email
          user.password = SecureRandom.hex(10)
          # add this authentication service to our new user
          s = user.services.build
          s.provider = provider
          s.uid = uid
          s.uname = name
          # do not send confirmation email, we directly save and confirm the new record
          user.skip_confirmation!
          user.save!
          user.confirm!
          s.save
          
          # flash and sign in
          flash[:notice] = 'Your account on Quantified Awesome has been created via ' + provider.capitalize + '. In your profile, you can change your personal information and add a local password.'
          sign_in_and_redirect(:user, user)
        end
      end
    end
  end
end
