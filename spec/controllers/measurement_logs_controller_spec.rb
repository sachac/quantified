require 'spec_helper'
describe MeasurementLogsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @measurement = create(:measurement, user: @user)
    @m = create(:measurement_log, measurement: @measurement)
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      assigns(:measurement_logs).should include(@m)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @m.id
      assigns(:measurement_log).should == @m
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new, measurement_id: @measurement.id
      assigns(:measurement_log).should be_new_record
      assigns(:measurement_log).user.id.should == @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @m.id
      assigns(:measurement_log).should == @m
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, measurement_log: { measurement_id: @measurement.id, notes: 'Hello world', value: 10, user_id: -1 }
      assigns(:measurement_log).user_id.should == @user.id
      assigns(:measurement_log).value.should be_within(0.1).of(10)
      flash[:notice].should == I18n.t('measurement_log.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_name = 'time it takes to make things happen'
      put :update, id: @m.id, measurement_log: { value: 11 }
      assigns(:measurement_log).value.should == 11
      flash[:notice].should == I18n.t('measurement_log.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @m.id
      lambda { @measurement.measurement_logs.find(@m.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(measurement_logs_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @m.id, format: :json
      response.response_code.should == 200
    end
  end

end
