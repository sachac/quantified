require 'spec_helper'
describe CsaFoodsController, :type => :controller  do
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
      expect(assigns(:csa_foods)).to include(@d)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @d.id
      expect(assigns(:csa_food)).to eq @d
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new, food_id: @food.id
      expect(assigns(:csa_food)).to be_new_record
      expect(assigns(:csa_food).user.id).to eq @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @d.id
      expect(assigns(:csa_food)).to eq @d
      expect(assigns(:csa_food).user_id).to eq @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, csa_food: { food_id: @food.id, notes: 'Hello world', user_id: -1 }
      expect(assigns(:csa_food).user_id).to eq @user.id
      expect(flash[:notice]).to eq I18n.t('csa_food.logged')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_note = 'blah'
      put :update, id: @d.id, csa_food: { notes: new_note }
      expect(flash[:notice]).to eq I18n.t('csa_food.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @d.id
      expect(lambda { @food.csa_foods.find(@d.id) }).to raise_exception(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(csa_foods_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @d.id, format: :json
      expect(response).to be_success
    end
  end

  describe 'POST quick_entry' do
    it "files the items" do
      post :quick_entry, food: 'potato', quantity: 1, unit: 'kg', date_received: '2013-01-02'
      # Potato and potatoes should be merged
      expect(Food.count).to eq 1
      expect(flash[:notice]).to eq I18n.t('csa_food.logged')
    end
    it "deals with errors" do
      allow_any_instance_of(CsaFood).to receive(:log).and_return(false)
      post :quick_entry, food: 'potatoes', quantity: 1, unit: 'kg'
      expect(response).to_not be_success
    end
  end
  describe 'POST bulk_update' do
    it "updates the dispositions" do
      @d2 = create(:csa_food, food: @food, quantity: '1', unit: 'kg', date_received: '2013-01-05')
      post :bulk_update, bulk: { @d.id => 'eaten' }
      expect(@d.reload.disposition).to eq 'eaten'
      expect(@d2.reload.disposition).to be_nil
    end
  end
end
