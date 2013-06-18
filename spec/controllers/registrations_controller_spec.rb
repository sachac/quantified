require 'spec_helper'
describe RegistrationsController do
  it "lets me register" do
    @request.env["devise.mapping"] = Devise.mappings[:user] #assuming your using :user routes
    post :create, user: { email: 'test@example.com' }
    response.should be_redirect
    flash[:notice].should =~ /Please check your e-mail/
  end
end
