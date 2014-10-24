require 'spec_helper'
describe DecisionLogsController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @decision = create(:decision, user: @user)
    @d = create(:decision_log, decision: @decision)
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      assigns(:decision_logs).should include(@d)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @d.id
      assigns(:decision_log).should == @d
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new, decision_id: @decision.id
      assigns(:decision_log).should be_new_record
      assigns(:decision_log).user.id.should == @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @d.id
      assigns(:decision_log).should == @d
      assigns(:decision_log).user_id.should == @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, decision_log: { decision_id: @decision.id, notes: 'Hello world', user_id: -1 }
      assigns(:decision_log).user_id.should == @user.id
      flash[:notice].should == I18n.t('decision_log.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_note = 'blah'
      put :update, id: @d.id, decision_log: { notes: new_note }
      flash[:notice].should == I18n.t('decision_log.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @d.id
      lambda { @decision.decision_logs.find(@d.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(decision_logs_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @d.id, format: :json
      response.response_code.should == 200
    end
  end

end
