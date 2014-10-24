require 'spec_helper'
include Warden::Test::Helpers

describe "User registrations", :type => :request do
  describe "POST /d/users" do
    it "reports an error if the passwords do not match" do
      post '/d/users', user: { email: 'test@example.com', password: 'PasswordX', password_confirmation: 'Does not match' }
      response.should_not be_redirect
      response.body.should match 'Password confirmation doesn'
    end
  end
end
