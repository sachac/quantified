require 'spec_helper'
describe ContextsController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    @context = create(:context, user: @user, name: 'Sample context')
    sign_in @user
  end
  describe 'GET index' do
    it "returns the list of contexts" do
      get :index
      expect(assigns(:contexts)).to eq [@context]
    end
  end
  describe 'POST create' do
    context 'with valid params' do
      it 'creates the object' do
        post :create, context: { name: 'Sample context 2' }
        expect(assigns(:context).name).to eq 'Sample context 2'
        expect(assigns(:context).id).to_not be_nil
      end
    end
    context 'with invalid params' do
      it 'reports an error' do
        allow_any_instance_of(Context).to receive(:save).and_return(false)
        post :create, context: { name: 'invalid' }
        expect(assigns(:context).id).to be_nil
      end
    end
  end
  
  describe 'GET show.json' do
    it "returns the JSON object" do
      get :show, id: @context.id, format: 'json'
      expect(JSON.parse(response.body).except('created_at', 'updated_at', 'context_rules')).to eq @context.attributes.except('created_at', 'updated_at', 'context_rules')
    end
    it "does not allow viewing of someone else's context" do
      context2 = create(:context)
      expect(lambda{ get :show, id: context2.id }).to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
  describe 'GET edit' do
    it "displays the edit form with at least five additional spots for rules" do
      get :edit, id: @context.id
      expect(assigns(:context).context_rules.size).to eq 5
    end
  end
  describe 'PUT update' do
    describe 'with valid parameters' do
      before do
        @stuff = Array.new
        @location = Array.new
        4.times do |i|
          @stuff << create(:stuff, name: "Item #{i}", user: @user)
          @location << create(:stuff, name: "Location #{i}", user: @user)
        end
        @context.context_rules << create(:context_rule, context: @context, stuff: @stuff[0], location: @location[0])
        @context.context_rules << create(:context_rule, context: @context, stuff: @stuff[1], location: @location[1])
        @context.context_rules << create(:context_rule, context: @context, stuff: @stuff[2], location: @location[0])
        data = {id: @context.id,
                context_rules_attributes:
                  {0 => {id: @context.context_rules[0].id, stuff: '', location: ''}, # gets deleted
                   1 => {id: @context.context_rules[1].id, stuff: 'Item 1', location: 'Location 1'}, # stays the same
                   2 => {id: @context.context_rules[2].id, stuff: 'Item 2', location: 'Location 2'}, # changes
                   3 => {stuff: 'Item 3', location: 'Location 3'}, # new rule
                   4 => {stuff: 'Item 4', location: 'Location 3'}, # new rule with new stuff
                   5 => {stuff: 'Item 5', location: 'Location 4'}, # new rule with new stuff and location
                  }}
        put :update, id: @context.id, context: data
        @context.reload 
      end
      subject { @context.context_rules }
      it "removes blank rules" do
        expect(subject[0].stuff).to_not eq @stuff[0]
      end
      it "keeps the same rules" do
        expect(subject[0].stuff).to eq @stuff[1]
        expect(subject[0].location).to eq @location[1]
      end
      it "updates previous rules" do
        expect(subject[1].stuff).to eq @stuff[2]
        expect(subject[1].location).to eq @location[2]
      end
      it "adds new rules" do
        expect(subject[2].stuff).to eq @stuff[3]
        expect(subject[2].location).to eq @location[3]
      end
      it "creates stuff if needed" do
        expect(subject[3].stuff.name).to eq 'Item 4'
        expect(subject[3].location).to eq @location[3]
      end
      it "creates locations if needed" do
        expect(subject[4].stuff.name).to eq 'Item 5'
        expect(subject[4].stuff.location.name).to eq 'Location 4'
      end
    end
    describe 'with invalid params' do
      it "assigns a newly created but unsaved receipt_item_type as @receipt_item_type" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ReceiptItemType).to receive(:save).and_return(false)
        context = create(:context, user: @user)
        post :update, id: context.id, context: {name: 'invalid'}
        assigns(:context).should eq(context)
      end
    end
  end
  describe 'DELETE destroy' do
    it "deletes the object" do
      delete :destroy, id: @context.id
      expect(response).to redirect_to(contexts_path)
    end
  end
end
