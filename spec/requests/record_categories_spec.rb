require 'spec_helper'
include Warden::Test::Helpers

RSpec.describe "RecordCategories", type: :request do
  describe "GET /record_category/:id/status" do
    it "gives the JSON information" do
      Timecop.freeze(2017, 1, 1, 8, 0) # 8:00 Jan 1
      @u = FactoryGirl.create(:confirmed_user)
      login_as @u, scope: :user

      cat = FactoryGirl.create(:record_category, category_type: 'activity', name: 'Category A', user: @u)
      one_hour_today = FactoryGirl.create(:record, record_category: cat, timestamp: Time.zone.now - 1.hour, user: @u)
      status = cat.status

      get status_record_category_path(id: cat.id, format: :json)
      json = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(json["duration"]).to eq 1.hour
      Timecop.return
    end
  end
end
