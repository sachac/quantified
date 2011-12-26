class SignupsController < ApplicationController
  respond_to :html, :json
  def index
    authorize! :manage, User
    @list = Signup.order('created_at DESC')
    respond_with @list
  end
end
