class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :notice_layout!

  def notice_layout!
    if ['mobile', 'full'].include? params[:layout]
      session[:layout] = params[:layout]
    end
  end
  protect_from_forgery
  MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

#  layout :select_layout
  def select_layout
    session.inspect # force session load
    if session.has_key? "layout"
      return (session["layout"] == "mobile") ? "mobile_application" : "application"
    end
    return mobile ? "mobile_application" : "application"
  end

  protected
  # http://stackoverflow.com/questions/1284169/mobile-version-of-views-for-ruby-on-rails
  def mobile
    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return m if agent.match(m)
    end
    false
  end
  
  def current_account
    if (current_subdomain.nil?)
      current_user || User.first
    else
      User.find_by_username(current_subdomain)  
    end
  end  
  # Make this method visible to views as well  
  helper_method :current_account  
    
  # This is a before_filter we'll use in other controllers  
  def account_required  
    unless current_account  
      flash[:error] = "Could not find the account '#{current_subdomain}'"  
      redirect_to :controller => "home", :action => "index", :subdomain => false  
    end
  end  
end
