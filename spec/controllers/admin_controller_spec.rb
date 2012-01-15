require 'spec_helper'

describe AdminController do
  describe '#invite_user' do
    it 'lets me invite users' do
      sign_in as_admin
      post :invite_user, :email => 'test@example.com'
      mail = ActionMailer::Base.deliveries.last
      mail.should_not be_nil
      puts mail.inspect
    end
  end
end
