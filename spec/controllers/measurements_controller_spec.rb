require 'rails_helper'
describe MeasurementsController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @m = create(:measurement, user: @user)
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      assigns(:measurements).should include(@m)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @m.id
      assigns(:measurement).should == @m
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new
      assigns(:measurement).should be_new_record
      assigns(:measurement).user_id.should == @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @m.id
      assigns(:measurement).should == @m
      assigns(:measurement).user_id.should == @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, measurement: { name: 'time it takes to run tests' }
      assigns(:measurement).name.should == 'time it takes to run tests'
      flash[:notice].should == I18n.t('measurement.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_name = 'time it takes to make things happen'
      put :update, id: @m.id, measurement: { name: new_name }
      assigns(:measurement).name.should == new_name
      flash[:notice].should == I18n.t('measurement.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @m.id
      lambda { @user.measurements.find(@m.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(measurements_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @m.id, format: :json
      response.response_code.should == 200
    end
  end

end
