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

  layout :select_layout
  # http://stackoverflow.com/questions/1284169/mobile-version-of-views-for-ruby-on-rails
  def select_layout
    session.inspect # force session load
    if session.has_key? "layout"
      return (session["layout"] == "mobile") ? "mobile_application" : "application"
    end
    return mobile ? "mobile_application" : "application"
  end
  def mobile
    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return m if agent.match(m)
    end
    false
  end
end
