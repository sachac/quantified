class Api::V1::TokensController  < ApplicationController      
  skip_before_action :verify_authenticity_token
  skip_authorization_check :only => [:create, :destroy]
  respond_to :json, :xml
  def create          
    login = params[:login] || (params[:user] and params[:user][:login])
    password = params[:password] || (params[:user] and params[:user][:password])
    if login.nil? or password.nil?
      status = 400
      message = {:message => "The request must contain the user login and password."}
    else
      @user = User.find_record(login)
      if @user.nil? || !@user.valid_password?(password)
        logger.info("User #{login} failed signin, user cannot be found.")
        status = 400; message = {:message => "Invalid login or password."}
      else
        status = 200; message = {:token => @user.authentication_token}
      end
    end
    respond_to do |format|
      format.json { render(:status => status, :json => message) and return }
      format.xml { render(:status => status, :xml => message) and return }
    end
    return
  end

  def destroy
    @user = User.find_by_authentication_token(params[:token])
    if @user.nil?
      logger.info("Token not found")
      status = 400; message = "Invalid token"
    else
      @user.reset_authentication_token!
      @user.save
      status = 200; message = {:token => @user.authentication_token}
    end
    respond_to do |format|
      format.json { render status: status, json: {message: message} }
      format.xml { render status: status, xml: {message: message} }
    end
    return
  end  

end
