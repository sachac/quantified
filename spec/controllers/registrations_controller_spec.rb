require 'rails_helper'
describe RegistrationsController, :type => :controller  do
  it "lets me register" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    post :create, user: { email: 'test@example.com', password: 'PasswordX', password_confirmation: 'PasswordX' }
    response.should be_redirect
    flash[:notice].should =~ /Please check your e-mail/
  end
  it "handles errors" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    allow_any_instance_of(User).to receive(:save).and_return(false)
    post :create, user: { email: 'test@example.com', password: 'PasswordX', password_confirmation: 'PasswordX' }
    response.should_not redirect_to(new_user_session_path)
  end
end
