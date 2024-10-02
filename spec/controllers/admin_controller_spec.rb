require 'rails_helper'
describe AdminController, :type => :controller  do
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
        expect(assigns(:users)).to include(u)
      end
    end
    describe 'POST become' do
      it "logs in as the specified user" do
        expect(session['warden.user.user.key'][0][0]).to eq @user.id
        u = create(:user, :confirmed)
        post :become, id: u
        expect(response).to redirect_to(root_url)
        expect(session['warden.user.user.key'][0][0]).to eq u.id
      end
    end
  end
  context "when logged in as a regular user" do
    it "denies access" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in create(:user, :confirmed)
      get :index
      expect(response).to redirect_to root_path
      expect(flash[:error]).to match /Access denied/
    end
  end
    
  
end
