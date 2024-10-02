
require 'rails_helper'
describe TapLogRecordsController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when logged in" do
    before do
      @user = create(:user, :confirmed)
      @records = Array.new
      base = Time.zone.now - 1.day + 5.hours
      @records << create(:tap_log_record, user: @user, timestamp: base, end_timestamp: base + 1.hour, catOne: 'Discretionary', catTwo: 'Gardening', duration: 3600, entry_type: 'activity')
      @records << create(:tap_log_record, user: @user, timestamp: base + 1.hour, end_timestamp: base + 2.hours, catOne: 'Discretionary', catTwo: 'Play', duration: 3600, entry_type: 'activity')
      @records << create(:tap_log_record, user: @user, timestamp: base + 2.hours, end_timestamp: base + 3.hours, catOne: 'Discretionary', catTwo: 'Play', note: '!private', duration: 3600, entry_type: 'activity')
      @records << create(:tap_log_record, user: @user, timestamp: base + 3.hours, catOne: 'Sleep', note: 'search string', duration: 3600, entry_type: 'activity')
      @records << create(:tap_log_record, user: @user, timestamp: base + 90.minutes, catOne: 'Text', note: 'search string', entry_type: 'note')
      @records << create(:tap_log_record, user: @user, timestamp: Time.zone.now - 5.days, catOne: 'Old', note: 'blah string', entry_type: 'note', duration: 3600)
      @records << create(:tap_log_record, user: @user, timestamp: base + 4.hours, catOne: 'Text', note: 'search string', entry_type: 'note')
      @tap_log_record = @records[1]
      sign_in @user
    end
    describe 'GET index' do
      it "returns the list" do
        get :index
      end
      it "filters by filter_string" do
        get :index, filter_string: 'search'
        assigns(:tap_log_records).should_not include @records[0]
        assigns(:tap_log_records).should include @records[3]
      end
      it "filters by category" do
        get :index, catOne: 'Discretionary'
        assigns(:tap_log_records).should include @records[0]
        assigns(:tap_log_records).should_not include @records[3]
      end
      it "filters by start time" do
        get :index, start: Time.zone.now - 2.days
        assigns(:tap_log_records).should_not include @records[5]
        assigns(:tap_log_records).should include @records[3]
      end
      it "filters by end time" do
        get :index, end: Time.zone.now - 2.days
        assigns(:tap_log_records).should_not include @records[0]
        assigns(:tap_log_records).should include @records[5]
        assigns(:total_duration).should == 3600
      end
      it "calculates duration" do
        get :index
        assigns(:total_duration).should == 3600 * 5
      end
    end
    describe 'GET show' do
      it "displays the item" do
        get :show, id: @tap_log_record.id
        assigns(:tap_log_record).should == @tap_log_record
        assigns(:next_activity).should == @records[2]
        assigns(:next_entry).should == @records[4]
        assigns(:during_this).should == [@records[4]]
      end
      it "includes during_this for open-ended activities" do
        get :show, id: @records[3].id
        assigns(:during_this).should == [@records[6]]
      end
    end
    describe 'GET new' do
      it "displays the new form" do
        get :new
        assigns(:tap_log_record).should be_new_record
      end
    end
    describe 'GET edit' do
      it "edits the item" do
        get :edit, id: @tap_log_record.id
        assigns(:tap_log_record).should == @tap_log_record
        assigns(:tap_log_record).user_id.should == @user.id
      end
    end
    describe 'POST create' do
      it "creates an item" do
        post :create, tap_log_record: { note: 'steak', timestamp: Time.zone.now, catOne: 'Foo' }
        assigns(:tap_log_record).note.should == 'steak'
        flash[:notice].should == I18n.t('tap_log_record.created')
      end
    end
    describe 'POST copy_to_memory' do
      it 'copies this tap log record' do
        @tap_log_record.note = 'Hello'
        @tap_log_record.save
        post :copy_to_memory, id: @tap_log_record.id
        assigns(:memory).body.should == 'Hello'
      end
    end
    describe 'PUT update' do
      it "updates the item" do
        put :update, id: @tap_log_record.id, tap_log_record: { note: 'potato' }
        assigns(:tap_log_record).note.should == 'potato'
        flash[:notice].should == I18n.t('tap_log_record.updated')
      end
    end
    describe 'DELETE destroy' do
      it "removes the item" do
        delete :destroy, id: @tap_log_record.id
        lambda { @user.tap_log_records.find(@tap_log_record.id) }.should raise_exception(ActiveRecord::RecordNotFound)
        response.should redirect_to(tap_log_records_url)
      end
    end
  end
  context "when viewing a demo account" do
    before do
      @user = create(:user, :demo)
      @records = Array.new
      @records << create(:tap_log_record, user: @user, timestamp: Time.zone.now - 1.day - 1.hour, catOne: 'Discretionary', catTwo: 'Play', note: '!private search')
      @records << create(:tap_log_record, user: @user, timestamp: Time.zone.now - 1.day - 1.hour, catOne: 'Sleep', note: 'search string')
    end
    describe 'GET index' do
      it "displays only public entries" do
        get :index, filter_string: 'search'
        assigns(:tap_log_records).should_not include @records[0]
        assigns(:tap_log_records).should include @records[1]
      end
    end
    describe 'GET show' do
      it "displays only public entries" do
        get :show, id: @records[0].id
        response.should be_redirect
      end
    end
  end
end
