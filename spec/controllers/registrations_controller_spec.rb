require 'spec_helper'
describe RegistrationsController do
  it "lets me register" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, user: { email: 'test@example.com' }
    response.should be_redirect
    flash[:notice].should =~ /Please check your e-mail/
  end
  it "handles errors" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    User.any_instance.stub(:save).and_return(false)
    post :create, user: { email: 'test@example.com' }
    response.should_not redirect_to(new_user_session_path)
  end
end
