require 'spec_helper'
describe ReceiptItemTypesController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
  end
  let(:valid_attributes) { attributes_for(:receipt_item_type, user: @user) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ReceiptItemTypesController. Be sure to keep this updated too.
  describe "GET index" do
    it "assigns all receipt_item_types as @receipt_item_types" do
      receipt_item_type = create(:receipt_item_type, user: @user)
      get :index, {}
      assigns(:receipt_item_types).should eq([receipt_item_type])
    end
  end

  describe "GET show" do
    it "assigns the requested receipt_item_type as @receipt_item_type" do
      receipt_item_type = create(:receipt_item_type, user: @user)
      get :show, {:id => receipt_item_type.to_param}
      assigns(:receipt_item_type).should eq(receipt_item_type)
    end
  end

  describe "GET new" do
    it "assigns a new receipt_item_type as @receipt_item_type" do
      get :new, {}
      assigns(:receipt_item_type).should be_a_new(ReceiptItemType)
    end
  end

  describe "GET edit" do
    it "assigns the requested receipt_item_type as @receipt_item_type" do
      receipt_item_type = create(:receipt_item_type, user: @user)
      get :edit, {:id => receipt_item_type.to_param}
      assigns(:receipt_item_type).should eq(receipt_item_type)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ReceiptItemType" do
        expect {
          post :create, {:receipt_item_type => valid_attributes}
        }.to change(ReceiptItemType, :count).by(1)
      end

      it "assigns a newly created receipt_item_type as @receipt_item_type" do
        post :create, {:receipt_item_type => valid_attributes}
        assigns(:receipt_item_type).should be_a(ReceiptItemType)
        assigns(:receipt_item_type).should be_persisted
      end

      it "redirects to the created receipt_item_type" do
        post :create, {:receipt_item_type => valid_attributes}
        response.should redirect_to(ReceiptItemType.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved receipt_item_type as @receipt_item_type" do
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItemType.any_instance.stub(:save).and_return(false)
        post :create, {:receipt_item_type => { "receipt_name" => "invalid value" }}
        assigns(:receipt_item_type).should be_a_new(ReceiptItemType)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItemType.any_instance.stub(:save).and_return(false)
        post :create, {:receipt_item_type => { "receipt_name" => "invalid value" }}
        flash[:notice].should be_blank
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested receipt_item_type" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        # Assuming there are no other receipt_item_types in the database, this
        # specifies that the ReceiptItemType created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ReceiptItemType.any_instance.should_receive(:update_attributes).with({ "receipt_name" => "MyString" })
        put :update, {:id => receipt_item_type.to_param, :receipt_item_type => { "receipt_name" => "MyString" }}
      end

      it "assigns the requested receipt_item_type as @receipt_item_type" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        put :update, {:id => receipt_item_type.to_param, :receipt_item_type => valid_attributes}
        assigns(:receipt_item_type).should eq(receipt_item_type)
      end

      it "redirects to the receipt_item_type" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        put :update, {:id => receipt_item_type.to_param, :receipt_item_type => valid_attributes}
        response.should redirect_to(receipt_item_type)
      end
    end

    describe "with invalid params" do
      it "assigns the receipt_item_type as @receipt_item_type" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItemType.any_instance.stub(:save).and_return(false)
        put :update, {:id => receipt_item_type.to_param, :receipt_item_type => { "receipt_name" => "invalid value" }}
        assigns(:receipt_item_type).should eq(receipt_item_type)
      end

      it "re-renders the 'edit' template" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItemType.any_instance.stub(:save).and_return(false)
        put :update, {:id => receipt_item_type.to_param, :receipt_item_type => { "receipt_name" => "invalid value" }}
        flash[:notice].should be_blank
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested receipt_item_type" do
      receipt_item_type = create(:receipt_item_type, user: @user)
      expect {
        delete :destroy, {:id => receipt_item_type.to_param}
      }.to change(ReceiptItemType, :count).by(-1)
    end

    it "redirects to the receipt_item_types list" do
      receipt_item_type = create(:receipt_item_type, user: @user)
      delete :destroy, {:id => receipt_item_type.to_param}
      response.should redirect_to(receipt_item_types_url)
    end
  end

end
