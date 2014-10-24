require 'spec_helper'
describe HomeController, :type => :controller  do
  it "shows a different mobile version" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in create(:user, :confirmed)
    get :index, layout: 'mobile'
    expect(@controller).to be_mobile
  end
  describe '#feedback' do
    it "fills in the current user by default" do
      @user = create(:user, :confirmed)
      sign_in @user
      get :feedback
      expect(assigns(:email)).to eq @user.email
    end
  end
  describe '#send_feedback' do
    it "asks people to fill in messages" do
      post :send_feedback
      expect(flash[:error]).to eq 'Please fill in your feedback message.'
    end
  end
end
