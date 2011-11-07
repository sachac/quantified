require 'spec_helper'
require 'awesome'
describe "Users" do
  it "allows users to log in with their e-mail" do
    @user = Factory(:user)
    login @user, :with => :email
    response.body.should include @user.username
  end
  it "allows users to log in with their username" do
    @user = Factory(:user)
    login @user, :with => :username
    response.body.should include @user.username
  end
end
