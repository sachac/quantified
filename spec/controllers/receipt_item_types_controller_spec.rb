require 'spec_helper'
describe ReceiptItemTypesController, :type => :controller  do
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
        allow_any_instance_of(ReceiptItemType).to receive(:save).and_return(false)
        post :create, {:receipt_item_type => { "receipt_name" => "invalid value" }}
        assigns(:receipt_item_type).should be_a_new(ReceiptItemType)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemType).to receive(:save).and_return(false)
        post :create, {:receipt_item_type => { "receipt_name" => "invalid value" }}
        flash[:notice].should be_blank
      end
    end
  end

  describe "PUT moveTo" do
    before :each do
      @type1 = create(:receipt_item_type, user: @user)
      @type2 = create(:receipt_item_type, user: @user)
      @type3 = create(:receipt_item_type, user: @user)
      @rec1 = create(:receipt_item, receipt_item_type: @type1, user: @user)
      @rec2 = create(:receipt_item, receipt_item_type: @type2, user: @user)
      @rec3 = create(:receipt_item, receipt_item_type: @type3, user: @user)
    end
    it "moves all the items from the specified item type to the other item type" do
      put :move_to, {:id => @type1.id, :new_id => @type2.id}
      @rec1.reload
      @rec1.receipt_item_type.id.should == @type2.id
      @rec3.reload
      @rec3.receipt_item_type.id.should == @type3.id
      @user.receipt_item_types.where(id: @type1.id).size.should == 0
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
        allow_any_instance_of(ReceiptItemType).to receive(:update_attributes).with({ "receipt_name" => "MyString" })
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

      it "returns the category name even in JSON" do
        type = create(:receipt_item_type, user: @user, receipt_name: 'Receipt item 1', friendly_name: 'This is a test')
        cat = create(:receipt_item_category, user: @user, name: 'Category A')
        put :update, {:id => type.to_param, :receipt_item_type => {receipt_item_category_id: cat.id}, format: :json}
        JSON.parse(response.body)['category_name'].should == 'Category A'
      end

    end

    describe "with invalid params" do
      it "assigns the receipt_item_type as @receipt_item_type" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemType).to receive(:save).and_return(false)
        put :update, {:id => receipt_item_type.to_param, :receipt_item_type => { "receipt_name" => "invalid value" }}
        assigns(:receipt_item_type).should eq(receipt_item_type)
      end

      it "re-renders the 'edit' template" do
        receipt_item_type = create(:receipt_item_type, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemType).to receive(:save).and_return(false)
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

  describe 'POST batch_entry' do
    before(:each) do
      poultry = create(:receipt_item_category, name: 'Poultry', user: @user)
      chicken = create(:receipt_item_type, receipt_name: 'CHKN', friendly_name: 'Chicken', receipt_item_category: poultry, user: @user)
      chicken_item = create(:receipt_item, name: 'CHKN', receipt_item_type: chicken, user: @user)
      unmapped_item = create(:receipt_item, name: 'CHKN BRST', user: @user)
      @poultry = poultry
    end
    it "displays only unmapped items" do
      get :batch_entry
      assigns(:unmapped).length.should == 1
    end
    it "confirms the data and creates records" do
      post :batch_entry, batch: {0 => {friendly_name: 'Chicken breast', receipt_name: 'CHKN BRST', receipt_item_category_id: @poultry.id}}
      assigns(:result).keys.first.should == 'CHKN BRST'
    end
  end

  describe 'autocomplete' do
    it "limits it to the user" do
      chicken = create(:receipt_item_type, receipt_name: 'CHKN', friendly_name: 'Chicken', receipt_item_category: @poultry, user: @user)
      chicken2 = create(:receipt_item_type, receipt_name: 'CHKN2', friendly_name: 'Chicken')
      get :autocomplete_receipt_item_type_friendly_name, term: 'Chick'
      JSON.parse(response.body).length.should == 1
    end
  end
end
