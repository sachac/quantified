require 'spec_helper'

describe ReceiptItemsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
  end

  let(:valid_attributes) { attributes_for(:receipt_item, user: @user) }

  describe "GET index" do
    it "assigns all receipt_items as @receipt_items" do
      receipt_item = create(:receipt_item, user: @user)
      receipt_item2 = create(:receipt_item)
      get :index
      assigns(:receipt_items).should eq([receipt_item])
    end
  end

  describe "GET show" do
    it "assigns the requested receipt_item as @receipt_item" do
      receipt_item = create(:receipt_item, user: @user)
      get :show, id: receipt_item.to_param
      assigns(:receipt_item).should eq(receipt_item)
    end
  end

  describe "GET new" do
    it "assigns a new receipt_item as @receipt_item" do
      get :new
      assigns(:receipt_item).should be_a_new(ReceiptItem)
    end
  end

  describe "GET edit" do
    it "assigns the requested receipt_item as @receipt_item" do
      receipt_item = create(:receipt_item, user: @user)
      get :edit, id: receipt_item.to_param
      assigns(:receipt_item).should eq(receipt_item)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ReceiptItem" do
        expect {
          post :create, {:receipt_item => valid_attributes}
        }.to change(ReceiptItem, :count).by(1)
      end

      it "assigns a newly created receipt_item as @receipt_item" do
        post :create, {:receipt_item => valid_attributes}
        assigns(:receipt_item).should be_a(ReceiptItem)
        assigns(:receipt_item).should be_persisted
      end

      it "redirects to the created receipt_item" do
        post :create, {:receipt_item => valid_attributes}
        response.should redirect_to(ReceiptItem.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved receipt_item as @receipt_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItem.any_instance.stub(:save).and_return(false)
        post :create, {:receipt_item => { "filename" => "invalid value" }}
        assigns(:receipt_item).should be_a_new(ReceiptItem)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItem.any_instance.stub(:save).and_return(false)
        post :create, {:receipt_item => { "filename" => "invalid value" }}
        flash[:notice].should be_nil
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested receipt_item" do
        receipt_item = create(:receipt_item, user: @user)
        # Assuming there are no other receipt_items in the database, this
        # specifies that the ReceiptItem created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ReceiptItem.any_instance.should_receive(:update_attributes).with({ "filename" => "MyString" })
        put :update, {:id => receipt_item.to_param, :receipt_item => { "filename" => "MyString" }}
      end

      it "assigns the requested receipt_item as @receipt_item" do
        receipt_item = create(:receipt_item, user: @user)
        put :update, {:id => receipt_item.to_param, :receipt_item => valid_attributes}
        assigns(:receipt_item).should eq(receipt_item)
      end

      it "redirects to the receipt_item" do
        receipt_item = create(:receipt_item, user: @user)
        put :update, {:id => receipt_item.to_param, :receipt_item => valid_attributes}
        response.should redirect_to(receipt_item)
      end
    end

    describe "with invalid params" do
      it "assigns the receipt_item as @receipt_item" do
        receipt_item = create(:receipt_item, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItem.any_instance.stub(:save).and_return(false)
        put :update, {:id => receipt_item.to_param, :receipt_item => { "filename" => "invalid value" }}
        assigns(:receipt_item).should eq(receipt_item)
      end

      it "re-renders the 'edit' template" do
        receipt_item = create(:receipt_item, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        ReceiptItem.any_instance.stub(:save).and_return(false)
        put :update, {:id => receipt_item.to_param, :receipt_item => { "filename" => "invalid value" }}
        flash[:notice].should be_nil
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested receipt_item" do
      receipt_item = create(:receipt_item, user: @user)
      expect {
        delete :destroy, {:id => receipt_item.to_param}
      }.to change(ReceiptItem, :count).by(-1)
    end

    it "redirects to the receipt_items list" do
      receipt_item = create(:receipt_item, user: @user)
      delete :destroy, {:id => receipt_item.to_param}
      response.should redirect_to(receipt_items_url)
    end
  end

  describe 'GET batch_entry' do
    it "displays the form" do
      get :batch_entry
    end
  end
  describe 'POST batch_entry' do
    let(:text) {
      'ID	File	Store	Date	Name	Quantity or net weight	Unit	Unit price	Total	Notes
2	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	RN Dried Apricot M	1		4	4	'
    }
    it "parses the batch" do
      post :batch_entry, batch: text
      assigns(:result).size.should == 1
    end
    it "confirms the data and creates records" do
      post :batch_entry, batch: text, confirm_data: 'confirmed'
      assigns(:outcome)[:created].size.should == 1
    end
    it "confirms the data and updates records" do
      x = create(:receipt_item, user: @user, source_name: 'batch', source_id: '2')
      post :batch_entry, batch: text, confirm_data: 'confirmed'
      assigns(:outcome)[:updated].size.should == 1
    end
    it "confirms the data and fails records" do
      ReceiptItem.any_instance.stub(:save).and_return(false)
      post :batch_entry, batch: text, confirm_data: 'confirmed'
      assigns(:outcome)[:failed].size.should == 1
    end
  end
end
