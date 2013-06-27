require 'spec_helper'
describe CsaFoodsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @food = create(:food, user: @user, name: 'potatoes')
    @d = create(:csa_food, food: @food, quantity: '1', unit: 'kg', date_received: '2013-01-01')
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      assigns(:csa_foods).should include(@d)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @d.id
      assigns(:csa_food).should == @d
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new, food_id: @food.id
      assigns(:csa_food).should be_new_record
      assigns(:csa_food).user.id.should == @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @d.id
      assigns(:csa_food).should == @d
      assigns(:csa_food).user_id.should == @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, csa_food: { food_id: @food.id, notes: 'Hello world', user_id: -1 }
      assigns(:csa_food).user_id.should == @user.id
      flash[:notice].should == I18n.t('csa_food.logged')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_note = 'blah'
      put :update, id: @d.id, csa_food: { notes: new_note }
      flash[:notice].should == I18n.t('csa_food.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @d.id
      lambda { @food.csa_foods.find(@d.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(csa_foods_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @d.id, format: :json
      response.should be_success
    end
  end

  describe 'POST quick_entry' do
    it "files the items" do
      post :quick_entry, food: 'potato', quantity: 1, unit: 'kg', date_received: '2013-01-02'
      # Potato and potatoes should be merged
      Food.count.should == 1
      flash[:notice].should == I18n.t('csa_food.logged')
    end
    it "deals with errors" do
      CsaFood.stub!(:log).and_return(false)
      post :quick_entry, food: 'potatoes', quantity: 1, unit: 'kg'
      response.should_not be_success
    end
  end
  describe 'POST bulk_update' do
    it "updates the dispositions" do
      @d2 = create(:csa_food, food: @food, quantity: '1', unit: 'kg', date_received: '2013-01-05')
      post :bulk_update, bulk: { @d.id => 'eaten' }
      @d.reload.disposition.should == 'eaten'
      @d2.reload.disposition.should be_nil
    end
  end
end
