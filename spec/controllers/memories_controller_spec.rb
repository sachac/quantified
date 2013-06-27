require 'spec_helper'
describe MemoriesController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
  end
  describe 'GET index' do
    context 'when other users view your memories' do
      it "shows only public ones" do
        u2 = create(:user, :demo)
        memory = create(:memory, :public, user: u2)
        memory2 = create(:memory, :private, user: u2)
        get :index
        assigns(:memories).should include(memory)
        assigns(:memories).should_not include(memory2)
      end
    end
    context 'when a tag is specified' do
      it "shows only items that were tagged" do
        sign_in @user
        memory = create(:memory, user: @user)
        memory.tag_list << 'foo'
        memory.save
        memory2 = create(:memory, user: @user)
        memory2.tag_list << 'baz'
        memory2.save
        get :index, tag: 'foo'
        assigns(:memories).should include(memory)
        assigns(:memories).should_not include(memory2)
      end
    end
  end
  context "when logged in" do
    before do
      sign_in @user
    end
    describe 'GET /memories/1' do
      it "displays the memory if we are allowed to view it" do
        memory = create(:memory, user: @user)
        get :show, id: memory.id
        assigns(:memory).should == memory
      end
      it "returns a 404 if we are not allowed to view it" do
        memory = create(:memory)
        lambda { get :show, id: memory.id }.should raise_exception(ActiveRecord::RecordNotFound)
      end
    end
    describe 'GET /memories/1/edit' do
      it "shows the edit form" do
        memory = create(:memory, user: @user)
        get :edit, id: memory.id
        assigns(:memory).should == memory
      end
      it "returns a 404 if we are not allowed to view it" do
        memory = create(:memory)
        lambda { get :edit, id: memory.id }.should raise_exception(ActiveRecord::RecordNotFound)
      end
    end
    describe 'POST /memories' do
      context 'when given an invalid memory' do
        it "does not show the success message" do
          Memory.any_instance.stub(:valid?).and_return(false)
          post :create
          flash[:notice].should be_nil
        end
      end
    end
    describe 'PUT /memories/1' do
      context "when given valid attributes" do
        it "updates the memory" do
          memory = create(:memory, user: @user)
          post :update, id: memory.id, memory: { body: 'Hello world' }
          flash[:notice].should == 'Memory was successfully updated.'
          response.should redirect_to(memories_path)
        end
      end
      context "when given invalid attributes" do
        it "does not display the success message" do
          memory = create(:memory, user: @user)
          Memory.any_instance.stub(:valid?).and_return(false)
          post :update, id: memory.id, memory: { body: 'Hello world' }
          flash[:notice].should be_nil
        end
      end
    end
    describe 'DELETE /memories/1' do
      context "when requesting HTML" do
        it "redirects to the memories path" do
          memory = create(:memory, user: @user)
          delete :destroy, id: memory.id
          response.should redirect_to(memories_path)
        end
      end
      context "when requesting a different format" do
        it "returns OK" do
          memory = create(:memory, user: @user)
          delete :destroy, id: memory.id, format: :json
          response.should be_success
        end
      end
    end
  end
end
