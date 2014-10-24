require 'spec_helper'
describe Api::V1::TokensController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
  end
  describe 'POST create' do
    it "requires a login and password" do
      post :create, format: :json
      JSON.parse(response.body)['message'].should == 'The request must contain the user login and password.'
    end
    it "authenticates if allowed" do
      post :create, format: :json, user: { login: @user.email, password: @user.password }
      JSON.parse(response.body)['token'].should_not be_nil
    end
    it "requires a valid user or password" do
      post :create, format: :json, user: { login: 'doesnotexist@example.com', password: 'incorrect password' }
      response.status.should == 400
    end
    it "responds to XML" do
      post :create, format: :xml, user: { login: 'doesnotexist@example.com', password: 'incorrect password' }
      response.status.should == 400
    end
  end
  describe 'DELETE' do
    it "requires a valid authentication token" do
      @user.ensure_authentication_token
      old_token = @user.authentication_token
      delete :destroy, token: old_token, format: :json
      @user.reload.authentication_token.should_not == old_token
      response.body.should match @user.reload.authentication_token
    end
    it "requires a valid token" do
      delete :destroy, token: "this does not exist", format: :json
      response.status.should == 400
    end
    it "handles XML" do
      @user.ensure_authentication_token
      old_token = @user.authentication_token
      delete :destroy, token: old_token, format: :xml
      response.body.should match @user.reload.authentication_token
    end
  end
end
