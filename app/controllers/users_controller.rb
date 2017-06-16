class UsersController < ApplicationController
  respond_to :html, :xml, :json
  # GET /users
  # GET /users.xml
  def index
    authorize! :manage, User
    @users = User.order('email')
    respond_with @users
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    authorize! :manage_account, @user
    respond_with @user
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    authorize! :create, User
    respond_with @user
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    authorize! :manage_account, @user
    respond_with @user
  end

  # POST /users
  # POST /users.xml
  def create
    authorize! :manage, User
    @user = User.new(user_params[:user])
    if @user.save
      add_flash :notice, I18n.t('user.created')
    end
    respond_with(@user)
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    authorize! :manage_account, @user
    if !params[:user].blank? and params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    params[:user].delete(:user_id)
    if params[:user][:settings]
      settings = params[:user][:settings]
      @user.settings.timezone = settings['time_zone']
      logger.info "Trying to set timezone? " + @user.settings.timezone
      params[:user].delete(:settings)
    end
    if @user.update_attributes(user_params[:user])
      add_flash :notice, I18n.t('user.updated')
    end
    respond_with(@user) do |format|
      format.html { redirect_to(edit_user_url(@user)) }
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    authorize! :manage_account, @user 
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.any  { head :ok }
    end
  end

  private
  def user_params
    params.permit(:user => [:email, :username, :password, :password_confirmation])
  end
end
