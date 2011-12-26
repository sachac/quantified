Rails.application.config.middleware.use OmniAuth::Builder do  
  provider :facebook, '297651176946994', '919210cdc875604ddee892f4a083b84c'   
  provider :twitter, '781510-F2ITvgEb4a8qG0aDKZo9oSCHOSZ2UPHD6thfjKkcX8', 'XIw7FXIt1EyRimxBaoSG7kShztyMeMwZ18ZZxMh5lM'
  require 'openid/store/filesystem'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid'
end
