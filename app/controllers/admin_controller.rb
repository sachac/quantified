class AdminController < ApplicationController
  def index
    authorize! :manage, User
    @signups = Signup.order('created_at DESC')
  end

end
