require 'spec_helper'
describe StuffController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    @stuff = create(:stuff, user: @user, status: 'active', name: 'ABC', created_at: Time.zone.now - 1.hour)
    @stuff2 = create(:stuff, user: @user, status: 'inactive', name: 'DEF')
    @stuff3 = create(:stuff, user: create(:user, :confirmed), status: 'inactive', name: 'DEF')
    sign_in @user
  end
  describe 'GET index' do
    it "sorts by date and then by name" do
      get :index, sort: '-created_at', status: 'all'
      assigns(:stuff).first.should == @stuff2
    end
    it "sorts by name by default if the column is not recognized" do
      get :index, sort: 'boo'
      assigns(:stuff).first.should == @stuff
    end
    it "shows stuff with a specific status" do
      get :index, status: 'inactive'
      assigns(:stuff).should_not include(@stuff)
      assigns(:stuff).should include(@stuff2)
    end
    it "shows all stuff" do
      get :index, status: 'all'
      assigns(:stuff).should include(@stuff)
      assigns(:stuff).should include(@stuff2)
    end
  end
  describe 'GET bulk' do
    it "displays the form" do
      get :bulk
    end
  end
  describe 'GET bulk_update' do
    it "updates stuff" do
      post :bulk_update, location: 'shelf', batch: "laptop"
      flash[:notice].should == 'Updated: laptop'
    end
    it "handles failure" do
      allow_any_instance_of(Stuff).to receive(:save).and_return(false)
      post :bulk_update, location: 'shelf', batch: "laptop"
      flash[:notice].should == 'Failed: laptop'
    end
  end
  describe 'GET show' do
    it "shows an item and its history" do
      @stuff.update_attributes(location: create(:stuff, user: @user))
      get :show, id: @stuff.id
      assigns(:stuff).should == @stuff
      assigns(:location_histories).should_not be_nil
    end
  end
  describe 'GET history' do
    it "returns the history" do
      @stuff.update_attributes(location: create(:stuff, user: @user))
      get :history, id: @stuff.id, format: :json
      assigns(:stuff).should == @stuff
      assigns(:location_histories).should_not be_nil
    end
    it "redirects HTML" do
      get :history, id: @stuff.id
      response.should redirect_to(@stuff)
    end
  end
  describe 'GET new' do
    it "shows the new stuff creation form" do
      get :new
      assigns(:stuff).should be_new_record
    end
  end
  describe 'GET edit' do
    it "shows the edit form" do
      get :edit, id: @stuff.id
      assigns(:stuff).should == @stuff
    end
  end
  describe 'POST create' do
    it "creates the item and sets the home location" do
      post :create, stuff: { home_location_id: @stuff2.id, name: 'Foo Item' }
      assigns(:stuff).home_location.should == @stuff2
      assigns(:stuff).location.should == @stuff2
      flash[:notice].should == I18n.t('stuff.created')
    end
  end
  describe 'PUT update' do
    it "updates the item and sets the home location" do
      put :update, id: @stuff.id, stuff: { home_location_id: @stuff2.id, name: 'Foo Item' }
      assigns(:stuff).home_location.should == @stuff2
      flash[:notice].should == I18n.t('stuff.updated')
    end
  end
  describe 'DELETE destroy' do
    it "removes the item" do
      delete :destroy, id: @stuff.id
      response.should redirect_to(stuff_index_path)
    end
  end
  describe 'autocomplete' do
    it "limits it to the user" do
      get :autocomplete_stuff_name, term: 'DEF'
      JSON.parse(response.body).length.should == 1
    end
  end
end
