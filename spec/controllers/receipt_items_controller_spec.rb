require 'spec_helper'

describe ReceiptItemsController, :type => :controller  do
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
    it "filters by name" do
      receipt_item = create(:receipt_item, user: @user, name: "ABC")
      receipt_item2 = create(:receipt_item, user: @user, name: "DEF")
      get :index, :filter_string => "D"
      assigns(:receipt_items).should eq([receipt_item2])
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

      it "sets up the friendly name if specified" do
        post :create, {:receipt_item => valid_attributes.merge(:friendly_name => 'Test Type',
                                                               :category_name => 'Meat')}
        assigns(:receipt_item).receipt_item_type.friendly_name.should eq 'Test Type'
        assigns(:receipt_item).receipt_item_type.receipt_item_category.name.should eq 'Meat'
        
      end

      it "returns the friendly name" do
        type = create(:receipt_item_type, user: @user, receipt_name: valid_attributes[:name])
        post :create, {:receipt_item => valid_attributes}
        assigns(:receipt_item).receipt_item_type_id.should == type.id
        assigns(:receipt_item).friendly_name.should eq type.friendly_name
      end

      it "returns the friendly name even in JSON" do
        type = create(:receipt_item_type, user: @user, receipt_name: 'Receipt item 1', friendly_name: 'This is a test')
        post :create, {:receipt_item => valid_attributes.merge(name: 'Receipt item 1'), format: :json}
        JSON.parse(response.body)['friendly_name'].should == type.friendly_name
      end

      it "redirects to the created receipt_item" do
        post :create, {:receipt_item => valid_attributes}
        response.should redirect_to(ReceiptItem.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved receipt_item as @receipt_item" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItem).to receive(:save).and_return(false)
        post :create, {:receipt_item => { "filename" => "invalid value" }}
        assigns(:receipt_item).should be_a_new(ReceiptItem)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItem).to receive(:save).and_return(false)
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
        expect_any_instance_of(ReceiptItem).to receive(:update_attributes).with({ "filename" => "MyString" })
        put :update, {:id => receipt_item.to_param, :receipt_item => { "filename" => "MyString" }}
      end

      it "returns the friendly name even in JSON" do
        type = create(:receipt_item_type, user: @user, receipt_name: 'Receipt item 1', friendly_name: 'This is a test')
        receipt_item = create(:receipt_item, name: 'Receipt item 1', user: @user)
        put :update, {:id => receipt_item.to_param, :receipt_item => {friendly_name: 'This is a test'}, format: :json}
        JSON.parse(response.body)['friendly_name'].should == type.friendly_name
        JSON.parse(response.body)['receipt_item_type_id'].should == type.id
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

      it "sets up the friendly name if specified" do
        receipt_item = create(:receipt_item, user: @user)
        put :update, {:id => receipt_item.to_param,
                      :receipt_item => valid_attributes.merge(:friendly_name => 'Test Type',
                                                              :category_name => 'Meat',
                                                              :receipt_item_type_id => nil)}
        assigns(:receipt_item).receipt_item_type.friendly_name.should eq 'Test Type'
        assigns(:receipt_item).receipt_item_type.receipt_item_category.name.should eq 'Meat'
      end

      it "can use category IDs" do
        receipt_item = create(:receipt_item, user: @user)
        c = create(:receipt_item_category, name: 'Meat', user: @user)
        put :update, {:id => receipt_item.to_param,
                      :receipt_item => valid_attributes.merge(:friendly_name => 'Test Type',
                                                              :receipt_item_category_id => c.id,
                                                              :receipt_item_type_id => nil)}
        assigns(:receipt_item).receipt_item_type.friendly_name.should eq 'Test Type'
        assigns(:receipt_item).receipt_item_type.receipt_item_category.name.should eq 'Meat'
      end
     
    end

    describe "with invalid params" do
      it "assigns the receipt_item as @receipt_item" do
        receipt_item = create(:receipt_item, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItem).to receive(:save).and_return(false)
        put :update, {:id => receipt_item.to_param, :receipt_item => { "filename" => "invalid value" }}
        assigns(:receipt_item).should eq(receipt_item)
      end

      it "re-renders the 'edit' template" do
        receipt_item = create(:receipt_item, user: @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItem).to receive(:save).and_return(false)
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
      allow_any_instance_of(ReceiptItem).to receive(:save).and_return(false)
      post :batch_entry, batch: text, confirm_data: 'confirmed'
      assigns(:outcome)[:failed].size.should == 1
    end
  end

  describe 'GET graph' do
    before :each do
      poultry = create(:receipt_item_category, name: 'Poultry', user: @user)
      chicken = create(:receipt_item_type, friendly_name: 'Chicken', receipt_item_category: poultry, user: @user)
      chicken_breast = create(:receipt_item_type, friendly_name: 'Chicken breast', receipt_item_category: poultry, user: @user)
      fruit = create(:receipt_item_category, name: 'Fruit', user: @user)
      grapefruit = create(:receipt_item_type, friendly_name: 'Grapefruit', receipt_item_category: fruit, user: @user)
      x = create(:receipt_item, user: @user, name: 'CHKN', receipt_item_type: chicken, total: 4, user: @user)
      y = create(:receipt_item, user: @user, name: 'CHKN', receipt_item_type: chicken, total: 5, user: @user)
      y = create(:receipt_item, user: @user, name: 'CHKN BREAST', receipt_item_type: chicken_breast, total: 6, user: @user)
      z = create(:receipt_item, user: @user, name: 'Grapefruit', receipt_item_type: grapefruit, total: 7, user: @user)
    end
    it "sums up the total" do
      get :graph
      assigns(:total).should == 4 + 5 + 6 + 7
    end
    it "sums up category totals" do
      get :graph
      assigns(:data)[:children][0][:name].should == 'Poultry'
      assigns(:data)[:children][0][:total].should == 4 + 5 + 6
    end
  end
end
