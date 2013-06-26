require 'spec_helper'
describe LibraryItemsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when logged in" do
    before do
      @user = create(:user, :confirmed)
      @card = create(:toronto_library, user: @user)
      sign_in @user
      @library_item = create(:library_item, title: 'Hello, world', user: @user, toronto_library: @card)
      @private_item = create(:library_item, title: 'Hello, world 2', user: @user, toronto_library: @card, public: 0)
    end
    describe 'GET index' do
      it "returns the list" do
        get :index
        assigns(:library_items).should include(@library_item)
      end
      it "reruns a CSV" do
        get :index, format: :csv
        assigns(:library_items).should include(@library_item)
      end
    end
    describe 'GET show' do
      it "displays the item" do
        get :show, id: @library_item.id
        assigns(:library_item).should == @library_item
      end
    end
    describe 'GET new' do
      it "displays the new form" do
        get :new
        assigns(:library_item).should be_new_record
      end
    end
    describe 'GET edit' do
      it "edits the item" do
        get :edit, id: @library_item.id
        assigns(:library_item).should == @library_item
        assigns(:library_item).user_id.should == @user.id
      end
    end
    describe 'POST create' do
      it "creates an item" do
        post :create, library_item: { title: 'Hello world again' }
        assigns(:library_item).title.should == 'Hello world again'
        flash[:notice].should == I18n.t('library_item.created')
      end
    end
    describe 'PUT update' do
      it "updates the item" do
        put :update, id: @library_item.id, library_item: { title: 'Hello world another' }
        assigns(:library_item).title.should == 'Hello world another'
        flash[:notice].should == I18n.t('library_item.updated')
      end
    end
    describe 'DELETE destroy' do
      it "removes the item" do
        delete :destroy, id: @library_item.id
        lambda { @user.library_items.find(@library_item.id) }.should raise_exception(ActiveRecord::RecordNotFound)
        response.should redirect_to(library_items_url)
      end
    end
    describe 'GET tag' do
      it "filters by tag" do
        @library_item.tag_list = 'hello'
        @library_item.save
        get :tag, id: 'hello'
        assigns(:library_items).should include(@library_item)
        assigns(:library_items).should_not include(@private_item)
      end
    end
    describe 'POST bulk' do
      it "renews" do
        TorontoLibrary.any_instance.should_receive(:renew_items)
        TorontoLibrary.any_instance.should_receive(:refresh_items)
        post :bulk, op: 'Renew', bulk: [ @library_item.id ]
      end
      it "makes public" do
        post :bulk, op: 'Make public', bulk: [ @private_item.id ]
        @private_item.reload.should be_public
      end
      it "makes private" do
        post :bulk, op: 'Make private', bulk: [ @library_item.id ]
        @library_item.reload.should_not be_public
      end
      it "marks read" do
        post :bulk, op: 'Mark read', bulk: [ @library_item.id ]
        @library_item.reload.status.should == 'read'
      end
    end
    describe 'GET current' do
      it "shows only non-returned items" do
        returned = create(:library_item, title: 'Returned item', user: @user, public: 1, toronto_library: @card, tag_list: 'hello', status: 'returned')
        get :current
        assigns(:library_items).should include(@library_item)
        assigns(:library_items).should_not include(returned)
      end
    end
  end
  context "when viewing a demo account" do
    before do
      @user = create(:user, :demo)
      @card = create(:toronto_library, user: @user)
      @library_item = create(:library_item, title: 'Hello, world', user: @user, toronto_library: @card, public: 1)
      @private_item = create(:library_item, title: 'Hello, world 2', user: @user, toronto_library: @card, public: 0)
    end
    describe 'GET index' do
      it 'shows only public items' do
        get :index
        assigns(:library_items).should include(@library_item)
        assigns(:library_items).should_not include(@private_item)
      end
    end
    describe 'GET show' do
      it 'shows only public items' do
        get :show, id: @library_item.id
        assigns(:library_item).should == @library_item
      end
      it 'does not show private items' do
        get :show, id: @private_item.id
        response.should be_redirect
      end
    end
    describe 'GET tag' do
      it "filters by tag" do
        tagged = create(:library_item, title: 'Tagged item', user: @user, public: 1, toronto_library: @card, tag_list: 'hello')
        get :tag, id: 'hello'
        assigns(:library_items).should include(tagged)
      end
    end
    describe 'GET current' do
      it "shows only public non-returned entries" do
        returned = create(:library_item, title: 'Returned item', user: @user, public: 1, toronto_library: @card, tag_list: 'hello', status: 'returned')
        get :current
        assigns(:library_items).should include(@library_item)
        assigns(:library_items).should_not include(returned)
        assigns(:library_items).should_not include(@private_item)
      end
    end
  end
end
