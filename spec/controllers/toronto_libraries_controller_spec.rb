require 'spec_helper'
describe TorontoLibrariesController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    @toronto_library = create(:toronto_library, user: @user)
  end
  describe 'GET index' do
    it "returns the list of library cards" do
      get :index
      assigns(:toronto_libraries).should include(@toronto_library)
    end
  end
  describe 'GET /toronto_libraries/1' do
    it "displays the item" do
      get :show, id: @toronto_library.id
      assigns(:toronto_library).should == @toronto_library
    end
  end
  describe 'GET /toronto_libraries/new' do
    it "displays the new toronto_library form" do
      get :new
      assigns(:toronto_library).should be_new_record
    end
  end
  describe 'GET /toronto_libraries/1/edit' do
    it "edits the toronto_library" do
      get :edit, id: @toronto_library.id
      assigns(:toronto_library).should == @toronto_library
    end
  end
  describe 'POST /toronto_libraries' do
    it "creates a toronto_library card" do
      post :create, toronto_library: { card: '12345', name: 'Foo' }
      assigns(:toronto_library).card.should == '12345'
      flash[:notice].should == I18n.t('toronto_library.created')
    end
  end
  describe 'PUT /toronto_libraries/1' do
    it "updates the toronto_library" do
      put :update, id: @toronto_library.id, toronto_library: { name: 'Bar' }
      assigns(:toronto_library).name.should == 'Bar'
      flash[:notice].should == I18n.t('toronto_library.updated')
    end
  end
  describe 'DELETE /toronto_libraries/1' do
    it "removes the toronto_library" do
      delete :destroy, id: @toronto_library.id
      lambda { @user.toronto_libraries.find(@toronto_library.id) }.should raise_exception(ActiveRecord::RecordNotFound)
      response.should redirect_to(toronto_libraries_url)
    end
  end

  describe 'POST /update' do
    it "refreshes the list" do
      TorontoLibrary.any_instance.should_receive(:refresh_items)
      post :refresh_all
    end
  end

  describe 'POST request_items' do
    context "when requests are successful" do
      it "returns a list of requested items" do
        TorontoLibrary.any_instance.stub(:login).and_return(:true)
        TorontoLibrary.any_instance.stub(:request_item).and_return(:true)
        post :request_items, id: @toronto_library.id, items: '12345678901234 blah 22345678901234'
        flash[:notice].should == 'Success: 12345678901234, 22345678901234'
      end
    end
    context "when requests are successful" do
      it "returns a list of failures" do
        TorontoLibrary.any_instance.stub(:login).and_return(true)
        TorontoLibrary.any_instance.stub(:request_item).and_return(false)
        post :request_items, id: @toronto_library.id, items: '12345678901234 blah 22345678901234'
        flash[:error].should == 'Error: 12345678901234, 22345678901234'
      end
    end
  end
end
