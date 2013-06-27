require 'spec_helper'
describe LocationHistoriesController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    stuff = create(:stuff, user: @user)
    stuff.location = create(:stuff, user: @user)
    stuff.save
    @stuff = stuff
    sign_in @user
  end
  describe 'GET /location_histories.csv' do
    it "returns the data" do
      get :index, format: :csv
      assigns(:data).last.stuff.should == @stuff
      assigns(:data).last.location.should == @stuff.location
    end
  end
  describe 'GET /location_histories' do
    it "returns the data" do
      get :index
      assigns(:data)[:entries].last.stuff.should == @stuff
      assigns(:data)[:entries].last.location.should == @stuff.location
    end
  end
  describe 'GET /location_histories/1' do
    it "shows the location history" do
      x = LocationHistory.last
      get :show, id: x.id
      assigns(:location_history).should == x
    end
  end
  describe 'DELETE /location_histories/1' do
    it "shows the location history" do
      x = LocationHistory.last
      delete :destroy, id: x.id
      response.should redirect_to(location_histories_path)
    end
  end
  
end
