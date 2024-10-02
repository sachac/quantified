require 'rails_helper'
describe DecisionsController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @d = create(:decision, user: @user)
  end
  describe 'GET index' do
    it "returns the list" do
      get :index
      expect(assigns(:decisions)).to include(@d)
    end
  end
  describe 'GET show' do
    it "displays the item" do
      get :show, id: @d.id
      expect(assigns(:decision)).to eq @d
    end
    it "returns JSON if requested" do
      get :show, id: @d.id, format: :json
      expect(JSON.parse(response.body).except('created_at', 'updated_at')).to eq JSON.parse(@d.to_json).except('created_at', 'updated_at')
    end
  end
  describe 'GET new' do
    it "displays the new form" do
      get :new
      expect(assigns(:decision)).to be_new_record
      expect(assigns(:decision).user_id).to eq @user.id
    end
  end
  describe 'GET edit' do
    it "edits the item" do
      get :edit, id: @d.id
      expect(assigns(:decision)).to eq @d
      expect(assigns(:decision).user_id).to eq @user.id
    end
  end
  describe 'POST create' do
    it "creates an item" do
      post :create, decision: { name: 'time it takes to run tests' }
      expect(assigns(:decision).name).to eq 'time it takes to run tests'
      expect(flash[:notice]).to eq I18n.t('decision.created')
    end
  end
  describe 'PUT update' do
    it "updates the item" do
      new_name = 'time it takes to make things happen'
      put :update, id: @d.id, decision: { name: new_name }
      expect(assigns(:decision).name).to eq new_name
      expect(flash[:notice]).to eq I18n.t('decision.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @d.id
      expect(lambda { @user.decisions.find(@d.id) }).to raise_exception(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(decisions_url)
    end
    it "allows XML/JSON deletion" do
      delete :destroy, id: @d.id, format: :json
      expect(response.response_code).to eq 200
    end
  end

end
