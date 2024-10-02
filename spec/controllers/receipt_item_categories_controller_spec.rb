require 'rails_helper'
describe ReceiptItemCategoriesController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
  end
  let(:valid_attributes) { attributes_for(:receipt_item_category, user: @user) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReceiptItemCategorysController. Be sure to keep this updated too.
  describe "GET index" do
    it "assigns all receipt_item_categories as @receipt_item_categories" do
      receipt_item_category = create(:receipt_item_category, user: @user)
      get :index, {}
      assigns(:receipt_item_categories).first.id.should == receipt_item_category.id
    end
  end

  describe "GET show" do
    it "assigns the requested receipt_item_category as @receipt_item_category" do
      receipt_item_category = create(:receipt_item_category, user: @user)
      get :show, {:id => receipt_item_category.to_param}
      assigns(:receipt_item_category).should eq(receipt_item_category)
    end
  end

  describe "GET new" do
    it "assigns a new receipt_item_category as @receipt_item_category" do
      get :new, {}
      assigns(:receipt_item_category).should be_a_new(ReceiptItemCategory)
    end
  end

  describe "GET edit" do
    it "assigns the requested receipt_item_category as @receipt_item_category" do
      receipt_item_category = create(:receipt_item_category, user: @user)
      get :edit, {:id => receipt_item_category.to_param}
      assigns(:receipt_item_category).should eq(receipt_item_category)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ReceiptItemCategory" do
        expect {
          post :create, {:receipt_item_category => valid_attributes}
        }.to change(ReceiptItemCategory, :count).by(1)
      end

      it "assigns a newly created receipt_item_category as @receipt_item_category" do
        post :create, {:receipt_item_category => valid_attributes}
        assigns(:receipt_item_category).should be_a(ReceiptItemCategory)
        assigns(:receipt_item_category).should be_persisted
      end

      it "redirects to the created receipt_item_category" do
        post :create, {:receipt_item_category => valid_attributes}
        response.should redirect_to(ReceiptItemCategory.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved receipt_item_category as @receipt_item_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemCategory).to receive(:save).and_return(false)
        post :create, {:receipt_item_category => { "name" => "invalid value" }}
        assigns(:receipt_item_category).should be_a_new(ReceiptItemCategory)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemCategory).to receive(:save).and_return(false)
        post :create, {:receipt_item_category => { "name" => "invalid value" }}
        flash[:notice].should be_blank
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested receipt_item_category" do
        receipt_item_category = create(:receipt_item_category, user: @user)
        # Assuming there are no other receipt_item_categories in the database, this
        # specifies that the ReceiptItemCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        allow_any_instance_of(ReceiptItemCategory).to receive(:update_attributes).with({ "name" => "MyString" })
        put :update, {:id => receipt_item_category.to_param, :receipt_item_category => { "name" => "MyString" }}
      end

      it "assigns the requested receipt_item_category as @receipt_item_category" do
        receipt_item_category = create(:receipt_item_category, user: @user)
        put :update, {:id => receipt_item_category.to_param, :receipt_item_category => valid_attributes}
        assigns(:receipt_item_category).should eq(receipt_item_category)
      end

      it "redirects to the receipt_item_category" do
        receipt_item_category = create(:receipt_item_category, user: @user)
        put :update, {:id => receipt_item_category.to_param, :receipt_item_category => valid_attributes}
        response.should redirect_to(receipt_item_category)
      end
    end

    describe "with invalid params" do
      it "assigns the receipt_item_category as @receipt_item_category" do
        receipt_item_category = create(:receipt_item_category, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemCategory).to receive(:save).and_return(false)
        put :update, {:id => receipt_item_category.to_param, :receipt_item_category => { "name" => "invalid value" }}
        assigns(:receipt_item_category).should eq(receipt_item_category)
      end

      it "re-renders the 'edit' template" do
        receipt_item_category = create(:receipt_item_category, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemCategory).to receive(:save).and_return(false)
        put :update, {:id => receipt_item_category.to_param, :receipt_item_category => { "name" => "invalid value" }}
        flash[:notice].should be_blank
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested receipt_item_category" do
      receipt_item_category = create(:receipt_item_category, user: @user)
      expect {
        delete :destroy, {:id => receipt_item_category.to_param}
      }.to change(ReceiptItemCategory, :count).by(-1)
    end

    it "redirects to the receipt_item_categories list" do
      receipt_item_category = create(:receipt_item_category, user: @user)
      delete :destroy, {:id => receipt_item_category.to_param}
      response.should redirect_to(receipt_item_categories_url)
    end
  end

end
