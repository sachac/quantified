require './lib/exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  check_authorization :unless => :devise_controller?
  handles_sortable_columns
  protect_from_forgery
  before_filter :before_awesome
  helper_method :current_account  
  helper_method :mobile?
  helper_method :managing?
  skip_filter :authenticate_user!

  def authenticate_managing!
    authorize! :manage_account, current_account
  end
  
  def mobile?
    session[:layout] == 'mobile'
  end

  def managing?
    can? :manage_account, current_account
  end

  def current_account
    current_user || User.where('role=?', 'demo').first || User.where('email=?', 'sacha@sachachua.com').first 
  end  

  protected

  def authenticate_admin!
    authenticate_user!
    raise CanCan::AccessDenied unless current_user and current_user.admin?
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      flash[:error] = I18n.t('error.access_denied_logged_in')
      if request.env['HTTP_REFERER']
        redirect_to :back
      else
        redirect_to root_path
      end
    else
      flash[:error] = exception.message
      redirect_to new_user_session_path
    end
  end

  def before_awesome
    notice_layout!
    @account = current_account
    # Set the timezone
    Time.zone = @account.settings.timezone if @account and @account.settings.timezone 
    true
  end
  def notice_layout!
    if ['mobile', 'full'].include? params[:layout]
      session[:layout] = params[:layout]
    end
    true
  end

  def after_sign_in_path_for(resource)
    if !params[:destination].blank?
      params[:destination]
    else
      stored_location_for(resource) || root_path
    end
  end

  def filter_sortable_column_order(list, default_sort = nil)
    result = default_sort || list.first
    sortable_column_order do |column, direction|
      if list.map(&:to_s).include? column.to_s
        result = "#{column} #{direction}"
      end
    end
    result
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

  def add_flash(symbol, value = '')
    if symbol.is_a? Hash
      symbol.each do |k,v| add_flash k, v end
    else
      if flash[symbol].blank?
        flash[symbol] = value
      else
        if flash[symbol].is_a? String
          flash[symbol] = [flash[symbol]]
        end
        flash[symbol] << value
      end
    end
  end

  def prepare_filters(symbols)
    @filters = Hash.new
    symbols = [symbols] unless symbols.is_a? Array
    symbols.each do |s|
      case s
      when :date_range
        @filters[:date_range] = true
        params[:start] ||= current_account.beginning_of_week.strftime('%Y-%m-%d')
        params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
      when :category_tree
        @filters[:category_tree] = true
        params[:category_tree] ||= 'tree'
      when :display_type
        @filters[:display_type] = true
        params[:display_type] ||= 'time'
      when :parent_id
        @filters[:parent_id] = true
      when :zoom_level
        @filters[:zoom_level] = true
        params[:zoom_level] ||= ''
      end
    end
  end


  def respond_with_data(data)
    if !request.format.csv?
      data = {
        :current_page => data.current_page,
        :per_page => data.per_page,
        :total_entries => data.total_entries,
        :entries => data
      }
    end
    respond_with(data)
  end
end

