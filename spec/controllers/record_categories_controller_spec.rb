
require 'spec_helper'
describe RecordCategoriesController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when logged in" do
    before do
      @user = create(:user, :confirmed)
      @cat = create(:record_category, user: @user, name: 'ABC')
      @subcat = create(:record_category, user: @user, parent: @cat, name: 'DEF')
      @record_category = create(:record_category, user: @user, name: 'GHI')
      @inactive = create(:record_category, user: @user, active: false, name: 'GHIJ')
      @ambig = create(:record_category, user: @user, active: true, name: 'GHIJK')
      sign_in @user
    end
    describe 'GET index' do
      it "returns top-level items by default" do
        get :index
        assigns(:record_categories).should include @cat
        assigns(:record_categories).should_not include @subcat
      end
      it "returns all items" do
        get :index, all: 1
        assigns(:record_categories).should include @cat
        assigns(:record_categories).should include @subcat
      end
    end
    describe 'GET show' do
      it "displays the item" do
        get :show, id: @record_category.id
        assigns(:record_category).should == @record_category
      end
      it "handles inactive items" do
        get :show, id: @inactive.id
        assigns(:title).should match I18n.t('general.inactive')
      end
      it "sorts in ascending order if requested" do
        @record = create(:record, record_category: @cat, timestamp: Time.zone.now - 1.hour)
        get :show, id: @cat.id, order: 'oldest'
        assigns(:records).all.should include @record
      end
      it "includes a summary of records for HTML/CSV" do
        @record = create(:record, record_category: @cat, timestamp: Time.zone.now - 1.hour)
        get :show, id: @cat.id
        assigns(:records).all.should include @record
        assigns(:total).should >= 3600
        assigns(:total_entries).should == 1
      end
      it "returns CSV" do
        @record = create(:record, record_category: @cat, timestamp: Time.zone.now - 1.hour, data: { note: 'Hello' })
        get :show, id: @cat.id, format: :csv
        assigns(:record_category).should == @cat
        assigns(:records).all.should include @record
      end
      it "returns JSON" do
        get :show, id: @cat.id, format: :json
        JSON.parse(response.body).should == JSON.parse(@cat.to_json)
      end
      it "returns XML" do
        get :show, id: @cat.id, format: :xml
        response.body.should == @cat.to_xml
      end
    end
    describe 'GET records' do
      it "returns a list of records" do
        @record = create(:record, record_category: @cat, timestamp: Time.zone.now - 1.hour)
        get :records, id: @cat.id
      end
      it "returns everything if CSV" do
        get :records, id: @cat.id, format: :csv
      end
    end
    
    describe 'GET new' do
      it "displays the new form" do
        get :new
        assigns(:record_category).should be_new_record
        assigns(:record_category).data.size.should > 0
      end
    end
    
    describe 'GET edit' do
      it "edits the item" do
        get :edit, id: @record_category.id
        assigns(:record_category).should == @record_category
        assigns(:record_category).user_id.should == @user.id
      end
    end
    describe 'POST create' do
      it "creates an item" do
        post :create, record_category: { name: 'blah', category_type: 'activity' }
        assigns(:record_category).name.should == 'blah'
        flash[:notice].should == I18n.t('record_category.created')
      end
      it "does not let me spoof user ID" do
        u2 = create(:user, :demo)
        post :create, record_category: { name: 'blah', user_id: u2.id, category_type: 'activity' }
        assigns(:record_category).user.should == @user
      end
      it "tracks a record if the timestamp was specified" do
        post :create, record_category: { name: 'blah', category_type: 'activity' }, timestamp: Time.zone.now - 1.hour
        Record.last.record_category.name.should == 'blah'
      end
    end
    describe 'PUT update' do
      it "updates the item" do
        put :update, id: @record_category.id, record_category: { name: 'blah', data: [ { 'key' => 'note', 'label' => 'Note', 'type' => 'text' } ] }
        assigns(:record_category).name.should == 'blah'
        flash[:notice].should == I18n.t('record_category.updated')
      end
      it "doesn't let me spoof user ID" do
        u2 = create(:user, :demo)
        put :update, id: @record_category.id, record_category: { name: 'blah', data: [ { 'key' => 'note', 'label' => 'Note', 'type' => 'text' } ], user_id: u2.id }
        assigns(:record_category).user_id.should == @user.id
        flash[:notice].should == I18n.t('record_category.updated')
      end
    end
    describe 'POST track' do
      it "creates a new time entry" do
        post :track, id: @record_category.id
        Record.last.record_category.should == @record_category
      end
    end
    describe 'POST bulk_update' do
      it "recalculates durations" do
        Record.should_receive(:recalculate_durations)
        post :bulk_update, commit: I18n.t('records.index.recalculate_durations')
      end
      it "updates category type" do
        post :bulk_update, category_type: { @cat.id => 'record' }
        @cat.reload.category_type.should == 'record'
      end
    end
    describe 'GET tree' do
      it "displays all record categories" do
        get :tree
        assigns(:list).should include @cat
        assigns(:list).should include @subcat
        assigns(:list).should include @record_category
        assigns(:list).should include @inactive
      end
    end
    describe 'GET disambiguate' do
      it "returns a list if needed" do
        get :disambiguate, category: 'GHI', timestamp: Time.zone.now - 1.hour
        assigns(:list).should include @record_category
        assigns(:list).should include @ambig
      end
      it "handles missing" do
        get :disambiguate, category: 'XYZ'
        flash[:error].should match 'Could not find category matching: XYZ.'
      end
      it "handles one item" do
        get :disambiguate, category: 'DEF'
        response.should be_redirect
      end
      it "strips out notes" do
        get :disambiguate, category: 'DEF | GHIJ'
        response.should be_redirect
      end
    end

    describe 'DELETE destroy' do
      it "removes the item" do
        delete :destroy, id: @record_category.id
        lambda { @user.record_categories.find(@record_category.id) }.should raise_exception(ActiveRecord::RecordNotFound)
        response.should redirect_to(record_categories_url)
      end
    end
  end
  context "when viewing a demo account" do
    before do
      @user = create(:user, :demo)
      @cat = create(:record_category, user: @user)
    end
    describe 'GET records' do
      before do
        @private = create(:record, :private, record_category: @cat, timestamp: Time.zone.now - 1.hour)
        @record = create(:record, record_category: @cat, timestamp: Time.zone.now - 1.hour)
      end
      it "displays only public entries" do
        get :records, id: @cat.id
        assigns(:records).should_not include(@private)
        assigns(:records).should include(@record)
      end
      it "displays only public entries as CSV" do
        get :records, id: @cat.id, format: :csv
        assigns(:records).should_not include(@private)
        assigns(:records).should include(@record)
      end
      it "displays only public entries as JSON" do
        get :records, id: @cat.id, format: :json
        assigns(:records).should_not include(@private)
        assigns(:records).should include(@record)
      end
      it "displays only public entries as XML" do
        get :records, id: @cat.id, format: :xml
        assigns(:records).should_not include(@private)
        assigns(:records).should include(@record)
      end
    end
  end
end
