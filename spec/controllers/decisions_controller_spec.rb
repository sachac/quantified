require 'spec_helper'
describe DecisionsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @d = create(:decision, user: @user)
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      assigns(:decisions).should include(@d)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @d.id
      assigns(:decision).should == @d
    end
    it "returns JSON if requested" do
      get :show, id: @d.id, format: :json
      JSON.parse(response.body).should == JSON.parse(@d.to_json)
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new
      assigns(:decision).should be_new_record
      assigns(:decision).user_id.should == @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @d.id
      assigns(:decision).should == @d
      assigns(:decision).user_id.should == @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, decision: { name: 'time it takes to run tests' }
      assigns(:decision).name.should == 'time it takes to run tests'
      flash[:notice].should == I18n.t('decision.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_name = 'time it takes to make things happen'
      put :update, id: @d.id, decision: { name: new_name }
      assigns(:decision).name.should == new_name
      flash[:notice].should == I18n.t('decision.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @d.id
      lambda { @user.decisions.find(@d.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(decisions_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @d.id, format: :json
      response.response_code.should == 200
    end
  end

end
