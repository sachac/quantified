require './lib/exceptions'
class ApplicationController < ActionController::Base
  include Exceptions
  check_authorization :unless => :devise_controller?
  protect_from_forgery
  respond_to :html, :json
  before_action :before_awesome
  before_action :authenticate_user_from_token!
      
  helper_method :current_account  
  helper_method :mobile?
  helper_method :managing?
  before_action :authenticate_user! # TODO, is this correct?

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
        redirect_back(fallback_location: root_path)
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
    # Detect the user if the username and password are specified
    if params[:username] and params[:password]
      u = User.find_record(params[:username])
      if u and u.valid_password?(params[:password])
        sign_in(User, u)
      end
    end

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
        params[:end] ||= (Time.zone.now + 1.day).strftime('%Y-%m-%d')
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
      when :filter_string
        @filters[:filter_string] = true
        params[:filter_string] ||= ''
      when :split
        @filters[:split] = true
        params[:split] ||= 'keep'
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


  # From https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_token!
    user_token = params[:auth_token].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
    if user
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in user, store: false
    end
  end
end

