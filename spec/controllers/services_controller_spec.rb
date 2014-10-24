require 'spec_helper'
describe ServicesController, :type => :controller  do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    omniauth_hash = { "provider" => "facebook", "uid" => "1234", "credentials" => {"token" => "abcdefg"}, "extra"=>{"raw_info" => {"id" => "1234567", "email" => "test@example.com", "name" => "Foo", "gender" => "male" }}}
    
    OmniAuth.config.add_mock(:facebook, omniauth_hash)
    omniauth_hash = { provider: "google",
      uid: "test@example.com",
      info: { name: "Jane Smith",
        email: "test@example.com" },
      credentials: {token: "testtoken234tsdf"},
    }
    OmniAuth.config.add_mock(:google, omniauth_hash)
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
  end
  describe 'POST create' do
    context "when the account exists" do
      before do
        @user = create(:user, :confirmed, email: 'test@example.com')
      end
      it "requires a service" do
        post :create
        flash[:error].should_not be_nil
        response.should redirect_to(new_user_session_path)
      end
      it "requires a uid" do
        OmniAuth.config.add_mock(:facebook, {uid: nil})
        request.env['omniauth.auth'] =
          {'provider' => 'facebook',
           'uid' => '',
           'extra' => { 'raw_info' => { 'email' => 'example@example.com',
                                        'name' => 'example',
                                        'id' => ''} } }
        post :create, service: 'facebook'
        flash[:error].should_not be_nil
        response.should redirect_to(new_user_session_path)
      end
      it "authenticates Facebook" do
        post :create, service: 'facebook'
        flash[:notice].should match 'Sign in via Facebook has been added to'
      end
      it "authenticates Google" do
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google]
        post :create, service: 'google'
        flash[:notice].should match 'Sign in via Google has been added to'
      end
      context "when I have oauthed before" do
        before do
          post :create, service: 'facebook'
          sign_out :user          
          post :create, service: 'facebook'
        end
        it "signs in if signed in before" do
          flash[:notice].should == 'Signed in successfully via Facebook.'
        end
        it "handles already being signed in and services already existing" do
          sign_in @user
          post :create, service: 'facebook'
          flash[:notice].should == 'Facebook is already linked to your account.'
          response.should redirect_to(root_path)
        end
      end
      it "handles already being signed in" do
        sign_in @user
        post :create, service: 'facebook'
        flash[:notice].should match 'Sign in via Facebook has been added to your account'
        response.should redirect_to(root_path)
      end
      it "authenticates Facebook" do
        post :create, service: 'facebook'
        flash[:notice].should match 'Signed in successfully'
      end
    end
    it "creates an account if necessary" do
      post :create, service: 'facebook'
      flash[:notice].should match /Your account on Quantified Awesome has been created via Facebook./
    end
    it "handles unknown services" do
      post :create, service: 'twitter'
      flash[:error].should match /Twitter cannot be used to sign up/
    end
  end
end
