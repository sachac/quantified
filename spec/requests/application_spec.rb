require 'spec_helper'
include Warden::Test::Helpers

describe ApplicationController, :type => :request do
  describe '#rescue_from CanCan::AccessDenied' do
    it "denies access if necessary" do
      login_as create(:user, :confirmed), scope: :user
      get admin_path, nil, {'HTTP_REFERER' => time_dashboard_path}
      expect(response).to redirect_to(time_dashboard_path)
    end
    it "redirects access denied to the main path" do
      login_as create(:user, :confirmed), scope: :user
      get admin_path
      expect(response).to redirect_to(root_path)
    end
    it "redirects new users to the login path" do
      get admin_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
  describe '#after_sign_in_path_for' do
    it "redirects to a destination after logging in if specified" do
      user = create(:user, :confirmed)
      post new_user_session_path, { user: { login: user.username, password: user.password }, destination: time_dashboard_path }
      response.should redirect_to(time_dashboard_path)
    end
    it "redirects to the main page after logging in" do
      user = create(:user, :confirmed)
      post new_user_session_path, { user: { login: user.username, password: user.password } }
      response.should redirect_to(root_path)
    end
  end
end
