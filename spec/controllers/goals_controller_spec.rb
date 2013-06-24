require 'spec_helper'
describe GoalsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @cat = create(:record_category, user: @user)
    @record = create(:record, record_category: @cat, user: @user, timestamp: Time.zone.now - 2.hours, end_timestamp: Time.zone.now - 1.hour)
    @goal = create(:goal, :today, user: @user, expression: "[#{@cat.name}] > 1")
  end
  describe 'GET /goals' do
    it "returns the goals" do
      get :index
      assigns(:goals).should include(@goal)
    end
    it "returns a CSV of the goals" do
      get :index, format: :csv
      assigns(:goals).should include(@goal)
    end
  end
  describe 'GET /goals/1' do
    it "displays the goal" do
      get :show, id: @goal.id
      assigns(:goal).should == @goal
    end
  end
  describe 'GET /goals/new' do
    it "displays the new goal form" do
      get :new
      assigns(:goal).should be_new_record
    end
  end
  describe 'GET /goals/1/edit' do
    it "edits the goal" do
      get :edit, id: @goal.id
      assigns(:goal).should == @goal
    end
  end
  describe 'POST /goals' do
    it "creates a goal" do
      post :create, goal: { expression: "[#{@cat.name}] > 1", period: "today", label: 'ABC goal' }
      assigns(:goal).period.should == 'today'
      flash[:notice].should == I18n.t('goals.created')
    end
  end
  describe 'PUT /goals/1' do
    it "updates the goal" do
      put :update, id: @goal.id, goal: { id: @goal.id, expression: "[#{@cat.name}] > 0.5", period: "today", label: 'ABC goal 2' }
      assigns(:goal).label.should == 'ABC goal 2'
      flash[:notice].should == I18n.t('goals.updated')
    end
  end
  describe 'DELETE /goals/1' do
    it "removes the goal" do
      delete :destroy, id: @goal.id
      lambda { @user.goals.find(@goal.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(goals_url)
    end
  end
end
