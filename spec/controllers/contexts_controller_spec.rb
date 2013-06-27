require 'spec_helper'
describe ContextsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    @context = create(:context, user: @user)
    sign_in @user
  end
  describe 'GET index' do
    it "returns the list of contexts" do
      get :index
      assigns(:contexts).should == [@context]
    end
  end
  describe 'GET show.json' do
    it "returns the JSON object" do
      get :show, id: @context.id, format: 'json'
      expected = @context.to_json
      response.body.should == expected
    end
    it "does not allow viewing of someone else's context" do
      context2 = create(:context)
      lambda{ get :show, id: context2.id }.should raise_exception(ActiveRecord::RecordNotFound)
    end
  end
  describe 'GET edit' do
    it "displays the edit form with at least five additional spots for rules" do
      get :edit, id: @context.id
      assigns(:context).context_rules.size.should == 5
    end
  end
  describe 'PUT update' do
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
      subject[0].stuff.should_not == @stuff[0]
    end
    it "keeps the same rules" do
      subject[0].stuff.should == @stuff[1]
      subject[0].location.should == @location[1]
    end
    it "updates previous rules" do
      subject[1].stuff.should == @stuff[2]
      subject[1].location.should == @location[2]
    end
    it "adds new rules" do
      subject[2].stuff.should == @stuff[3]
      subject[2].location.should == @location[3]
    end
    it "creates stuff if needed" do
      subject[3].stuff.name.should == 'Item 4'
      subject[3].location.should == @location[3]
    end
    it "creates locations if needed" do
      subject[4].stuff.name.should == 'Item 5'
      subject[4].stuff.location.name.should == 'Location 4'
    end
  end
  describe 'DELETE destroy' do
    it "deletes the object" do
      delete :destroy, id: @context.id
      response.should redirect_to(contexts_path)
    end
  end
end
