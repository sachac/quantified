require 'spec_helper'
describe SessionsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  describe 'GET setup' do
    it "returns a page not found" do
      get :setup, service: :google
      response.status.should == 404
    end
  end
  describe 'POST create.json' do
    it "logs in" do
      @user = create(:user, :confirmed)
      post :create, scope: 'user', user: { login: @user.email, password: @user.password }, format: :json
      JSON.parse(response.body)["success"].should be_true
    end
  end
end
