require 'spec_helper'
describe AdminController do
  context "when logged in as an administrator" do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, :admin)
      sign_in @user
    end
    describe 'GET /index' do
      it "shows the list of users" do
        u = create(:user, :confirmed)
        get :index
        assigns(:users).all.should include(u)
      end
    end
    describe 'POST become' do
      it "logs in as the specified user" do
        session['warden.user.user.key'][0][0].should == @user.id
        u = create(:user, :confirmed)
        post :become, id: u
        response.should redirect_to(root_url)
        session['warden.user.user.key'][0][0].should == u.id
      end
    end
  end
  context "when logged in as a regular user" do
    it "denies access" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in create(:user, :confirmed)
      get :index
      response.should redirect_to root_path
      flash[:error].should match /Access denied/
    end
  end
    
  
end
