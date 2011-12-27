require 'lib/exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  check_authorization :unless => :devise_controller?
  protect_from_forgery
  before_filter :before_awesome
  helper_method :current_account  
  helper_method :mobile?
  helper_method :managing?
  skip_filter :authenticate_user!

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
    stored_location_for(resource) || root_path
  end

  def filter_sortable_column_order(list)
    result = list.first
    sortable_column_order do |column, direction|
      if list.map(&:to_s).include? column.to_s
        result = "#{column} #{direction}"
      end
    end
#     sortable_column_order
  end

  def go_to(url, options = {})
    add_flash :notice, options[:notice] if options[:notice]
    add_flash :error, options[:error] if options[:error]
    if params[:destination].blank?
      redirect_to url
    else
      redirect_to params[:destination]
    end
  end

  def add_flash(symbol, value)
    if flash[symbol].blank?
      flash[symbol] = value
    else
      if flash[symbol].is_a? String
        flash[symbol] = [flash[symbol]]
      end
      flash[symbol] << value
    end
  end

  def prepare_filters(symbols)
    @filters = Hash.new
    symbols.each do |s|
      case s
      when :date_range
        @filters[:date_range] = true
        params[:start] ||= current_account.beginning_of_week.strftime('%Y-%m-%d')
        params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
      when :category_tree
        @filters[:category_tree] = true
        params[:category_tree] ||= 'tree'
      end
    end
  end


  def mobile?
    session[:layout] == 'mobile'
  end

  def managing?
    can? :manage_account, current_account
  end

  def html?
    params[:format].blank? or params[:format] == 'html'
  end

  def json_paginate(entries)
    {
      :current_page => entries.current_page,
      :per_page => entries.per_page,
      :total_entries => entries.total_entries,
      :entries => entries
    }
  end
end
