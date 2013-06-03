require 'spec_helper'
include Warden::Test::Helpers

describe "TimelineEvents" do
  describe "GET /timeline_events" do
    it "works! (now write some real specs)" do
      @user = FactoryGirl.create(:admin)
      login_as @user, scope: :user
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get timeline_events_path
      response.status.should be(200)
    end
  end
end
