require 'rails_helper'
describe FoodsController, :type => :controller  do
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
      expect(assigns(:info)[@food.id][:total]).to eq 7
      expect(assigns(:info)[@food.id][:remaining]).to eq 3
      expect(assigns(:foods)).to include(@food)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @food.id
      expect(assigns(:food)).to eq @food
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new
      expect(assigns(:food)).to be_new_record
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @food.id
      expect(assigns(:food)).to eq @food
      expect(assigns(:food).user_id).to eq @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, food: { name: 'steak' }
      expect(assigns(:food).name).to eq 'steak'
      expect(flash[:notice]).to eq I18n.t('food.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      put :update, id: @food.id, food: { name: 'potato' }
      expect(assigns(:food).name).to eq 'potato'
      expect(flash[:notice]).to eq I18n.t('food.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @food.id
      expect(lambda { @user.foods.find(@food.id) }).to raise_exception(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(foods_url)
    end
  end
end
