require 'spec_helper'
include Warden::Test::Helpers

describe "TimelineEvents", :type => :request do
  describe "GET /timeline_events" do
    it "works! (now write some real specs)" do
      @user = FactoryGirl.create(:admin)
      login_as @user, scope: :user
      get timeline_events_path
      expect(response.status).to be(200)
    end
  end
end
