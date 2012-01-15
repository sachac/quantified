require 'spec_helper'
describe RegistrationsController do
  include Devise::TestHelpers
  describe '#create' do
    it "allows users to sign up" do
      post :create, :user => { :email => 'test@example.com' }
      response.body.should include "Thank you!"
    end
  end
end
