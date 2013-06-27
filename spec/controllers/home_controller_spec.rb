require 'spec_helper'
describe HomeController do
  it "shows a different mobile version" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in create(:user, :confirmed)
    get :index, layout: 'mobile'
    @controller.should be_mobile
  end
  describe '#feedback' do
    it "fills in the current user by default" do
      @user = create(:user, :confirmed)
      sign_in @user
      get :feedback
      assigns(:email).should == @user.email
    end
  end
  describe '#send_feedback' do
    it "asks people to fill in messages" do
      post :send_feedback
      flash[:error].should == 'Please fill in your feedback message.'
    end
  end
end
