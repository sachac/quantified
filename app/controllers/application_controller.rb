require 'lib/exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  check_authorization :unless => :devise_controller?
  protect_from_forgery
  before_filter :before_awesome
  helper_method :current_account  
  
  rescue_from NonexistentAccount do |e|
    logger.info "NONEXISTENT #{current_subdomain}"
    flash[:error] = I18n.t('app.error.nonexistent_account')
    redirect_to root_url(:subdomain => false)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = exception.message
    redirect_to new_user_session_path
  end

  def before_awesome
    notice_layout!
    @account = current_account
    true
  end
  def notice_layout!
    if ['mobile', 'full'].include? params[:layout]
      session[:layout] = params[:layout]
    end
    true
  end

  def current_account
    if (current_subdomain.nil?)
      current_user || User.first
    else
      u = User.find_by_username(current_subdomain)  
      if u.nil? # nonexistent
        raise NonexistentAccount
      end
      u
    end
  end  

  def after_sign_in_path_for(resource)
    logger.info "LOG IN #{resource.inspect} #{resource.username}"
    stored_location_for(resource) || root_url(:subdomain => resource.username)
  end

  def filter_sortable_column_order(list)
    sortable_column_order do |column, direction|
      if list.include? column
        result = "#{column} #{direction}"
      end
    end
    result ||= list.first
  end
end
