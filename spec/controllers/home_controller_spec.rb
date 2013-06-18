require 'spec_helper'
describe HomeController do
  it "shows a different mobile version" do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    get :index, { layout: 'mobile' }
    @controller.should be_mobile
  end
end
