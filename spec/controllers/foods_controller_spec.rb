require 'spec_helper'
describe FoodsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @food = create(:food, name: 'potatoes', user: @user)
    @csa_food = create(:csa_food, user: @user, food: @food, quantity: 1, unit: 'kg')
    @csa_food2 = create(:csa_food, user: @user, food: @food, quantity: 2, unit: 'kg', date_received: Time.zone.today - 1.week)
    @csa_food3 = create(:csa_food, user: @user, food: @food, quantity: 4, unit: 'kg', date_received: Time.zone.today - 2.week, disposition: 'ate them all')
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      assigns(:info)[@food.id][:total].should == 7
      assigns(:info)[@food.id][:remaining].should == 3
      assigns(:foods).should include(@food)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @food.id
      assigns(:food).should == @food
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new
      assigns(:food).should be_new_record
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @food.id
      assigns(:food).should == @food
      assigns(:food).user_id.should == @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, food: { name: 'steak' }
      assigns(:food).name.should == 'steak'
      flash[:notice].should == I18n.t('food.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      put :update, id: @food.id, food: { name: 'potato' }
      assigns(:food).name.should == 'potato'
      flash[:notice].should == I18n.t('food.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @food.id
      lambda { @user.foods.find(@food.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(foods_url)
    end
  end
end
