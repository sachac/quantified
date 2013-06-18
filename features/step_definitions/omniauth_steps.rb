Before('@omniauth_test') do
    OmniAuth.config.test_mode = true

    # the symbol passed to mock_auth is the same as the name of the provider set up in the initializer
    OmniAuth.config.mock_auth[:google] = {
          "provider"=>"google",
          "uid"=>"http://xxxx.com/openid?id=118181138998978630963",
          "user_info"=>{"email"=>"test@xxxx.com", "first_name"=>"Test", "last_name"=>"User", "name"=>"Test User"}
      }
  end

After('@omniauth_test') do
  OmniAuth.config.test_mode = false
end
