require 'spec_helper'

RSpec.describe GroceryListsController, :type => :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
  end

  # This should return the minimal set of attributes required to create a valid
  # GroceryList. As you add validations to GroceryList, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    attributes_for(:grocery_list, user: @user)
  }

  let(:invalid_attributes) {
    {name: ''}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GroceryListsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all grocery_lists as @grocery_lists" do
      grocery_list = GroceryList.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:grocery_lists)).to eq([grocery_list])
    end
  end

  describe "GET show" do
    it "assigns the requested grocery_list as @grocery_list" do
      grocery_list = GroceryList.create! valid_attributes
      get :show, {:id => grocery_list.to_param}, valid_session
      expect(assigns(:grocery_list)).to eq(grocery_list)
    end
  end

  describe "GET new" do
    it "assigns a new grocery_list as @grocery_list" do
      get :new, {}, valid_session
      expect(assigns(:grocery_list)).to be_a_new(GroceryList)
    end
  end

  describe "GET edit" do
    it "assigns the requested grocery_list as @grocery_list" do
      grocery_list = GroceryList.create! valid_attributes
      get :edit, {:id => grocery_list.to_param}, valid_session
      expect(assigns(:grocery_list)).to eq(grocery_list)
    end
  end

  describe "POST quick_add_to" do
    describe "with invalid params" do
      it "reports an error" do
        grocery_list = GroceryList.create! valid_attributes
        allow_any_instance_of(GroceryListItem).to receive(:save).and_return false
        post :quick_add_to, {id: grocery_list.to_param, quick_add: 'Apples'}, valid_session
        expect(flash[:error]).to_not be_nil
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new GroceryList" do
        expect {
          post :create, {:grocery_list => valid_attributes}, valid_session
        }.to change(GroceryList, :count).by(1)
      end

      it "assigns a newly created grocery_list as @grocery_list" do
        post :create, {:grocery_list => valid_attributes}, valid_session
        expect(assigns(:grocery_list)).to be_a(GroceryList)
        expect(assigns(:grocery_list)).to be_persisted
      end

      it "redirects to the created grocery_list" do
        post :create, {:grocery_list => valid_attributes}, valid_session
        expect(response).to redirect_to(GroceryList.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved grocery_list as @grocery_list" do
        allow_any_instance_of(GroceryList).to receive(:save).and_return false
        post :create, {:grocery_list => invalid_attributes}, valid_session
        expect(assigns(:grocery_list)).to be_a_new(GroceryList)
      end

      it "re-renders the 'new' template" do
        allow_any_instance_of(GroceryList).to receive(:valid?).and_return false
        allow_any_instance_of(GroceryList).to receive(:errors).and_return [:name]
        post :create, {:grocery_list => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        attributes_for(:grocery_list, user: @user, name: 'Updated')
      }

      it "updates the requested grocery_list" do
        grocery_list = GroceryList.create! valid_attributes
        put :update, {:id => grocery_list.to_param, :grocery_list => new_attributes}, valid_session
        grocery_list.reload
        expect(grocery_list.name).to eq 'Updated'
      end

      it "assigns the requested grocery_list as @grocery_list" do
        grocery_list = GroceryList.create! valid_attributes
        put :update, {:id => grocery_list.to_param, :grocery_list => valid_attributes}, valid_session
        expect(assigns(:grocery_list)).to eq(grocery_list)
      end

      it "redirects to the grocery_list" do
        grocery_list = GroceryList.create! valid_attributes
        put :update, {:id => grocery_list.to_param, :grocery_list => valid_attributes}, valid_session
        expect(response).to redirect_to(grocery_list)
      end
    end

    describe "with invalid params" do
      it "assigns the grocery_list as @grocery_list" do
        grocery_list = GroceryList.create! valid_attributes
        put :update, {:id => grocery_list.to_param, :grocery_list => invalid_attributes}, valid_session
        expect(assigns(:grocery_list)).to eq(grocery_list)
      end

      it "re-renders the 'edit' template" do
        grocery_list = GroceryList.create! valid_attributes
        put :update, {:id => grocery_list.to_param, :grocery_list => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested grocery_list" do
      grocery_list = GroceryList.create! valid_attributes
      expect {
        delete :destroy, {:id => grocery_list.to_param}, valid_session
      }.to change(GroceryList, :count).by(-1)
    end

    it "redirects to the grocery_lists list" do
      grocery_list = GroceryList.create! valid_attributes
      delete :destroy, {:id => grocery_list.to_param}, valid_session
      expect(response).to redirect_to(grocery_lists_url)
    end
  end

end
