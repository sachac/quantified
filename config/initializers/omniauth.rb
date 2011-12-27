Rails.application.config.middleware.use OmniAuth::Builder do  
  require 'openid/store/filesystem'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid'
end
