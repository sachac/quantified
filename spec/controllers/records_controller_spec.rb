require 'rails_helper'
# TODO Move these to request specs
describe RecordsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when logged in" do
    before do
      travel_to Time.zone.local(2017, 1, 1)
      @user = create(:user, :confirmed)
      sign_in @user
      @cat = create(:record_category, user: @user, name: 'ABC')
      @cat2 = create(:record_category, user: @user, name: 'DEF')
      @cat3 = create(:record_category, user: @user, name: 'GHI')
      @cat4 = create(:record_category, user: @user, name: 'GHIJ')
      @record = create(:record, record_category: @cat, user: @user, timestamp: Time.zone.now - 2.hours, end_timestamp: Time.zone.now - 1.hour)
      @record2 = create(:record, record_category: @cat, user: @user, timestamp: Time.zone.now - 1.hour, end_timestamp: Time.zone.now)
      start = Time.zone.local(2013, 1, 1, 23)
      @record3 = create(:record, record_category: @cat4, source_name: 'older', user: @user, timestamp: start, end_timestamp: start + 3.hours)
      @record4 = create(:record, record_category: @cat4, source_name: 'older', user: @user, timestamp: start + 3.hours, end_timestamp: start + 4.hours)
    end
    after do
      travel_back
    end
    describe 'GET /records' do
      it "returns the records" do
        get :index
        assigns(:records).should include(@record)
      end
      it "returns a CSV of the records" do
        get :index, format: :csv
        assigns(:records).should include(@record)
      end
      it "filters by time if specified" do
        get :index, start: Time.zone.now - 90.minutes
        assigns(:records).should include(@record2)
        assigns(:records).should include(@record)
        assigns(:records).should_not include(@record4)
      end
      it "recalculates durations if needed" do
        get :index, commit: I18n.t('records.index.recalculate_durations')
        @record3.reload.duration.should == 3 * 60 * 60
      end
      it "shows reverse-chronological by default" do
        get :index
        assigns(:records).first.should == @record2
      end
      it "shows chronological if requested" do
        get :index, order: 'oldest'
        assigns(:records).last.should == @record2
        assigns(:records).first.should == @record3
      end
      it "splits by midnight if requested" do
        get :index, split: 'split'
        assigns(:records).last.duration.should == 3600
      end
      it "splits by midnight for CSVs, too" do
        get :index, split: 'split', format: :csv
        assigns(:records).last.duration.should == 3600
      end
    end
    describe 'GET /records/1' do
      it "displays the record" do
        get :show, id: @record.id
        assigns(:record).should == @record
      end
    end
    describe 'GET /records/new' do
      it "displays the new record form" do
        get :new
        assigns(:record).should be_new_record
      end
    end
    describe 'GET /records/1/edit' do
      it "edits the record" do
        get :edit, id: @record.id
        assigns(:record).should == @record
      end
    end
    describe 'POST /records' do
      it "creates a record when given a timestamp" do
        post :create, record: { timestamp: Time.zone.now - 1.hour, record_category_id: @cat.id }
        flash[:notice].should == I18n.t('record.created')
      end
    end
    describe 'PUT /records/1' do
      it "updates the record" do
        put :update, id: @record.id, record: { id: @record.id, timestamp: Time.zone.now - 2.hours }
        flash[:notice].should == I18n.t('record.updated')
      end
      it "updates a record with a note" do
        put :update, id: @record.id, record: { id: @record.id, timestamp: Time.zone.now - 2.hours, data: { note: 'This is a note' }}
        expect(@record.reload.data['note']).to eq 'This is a note'
      end
    end
    describe 'DELETE /records/1' do
      it "removes the record" do
        delete :destroy, id: @record.id
        lambda { @user.records.find(@record.id) }.should raise_exception(ActiveRecord::RecordNotFound)
        response.should redirect_to(records_url)
      end
    end
    describe 'POST clone' do
      it "copies the record" do
        post :clone, id: @record.id
        assigns(:record).should be_new_record
        assigns(:record).record_category_id.should == @record.record_category_id
      end
    end
    describe 'POST batch' do
      it "parses and confirms the entries" do
        post :batch, batch: "1:00 ABC\n2:00 DEF\n3:00 3:30 GHI\n4:00 Unknown", date: '2013-01-01'
        assigns(:records)[0][:timestamp].hour.should == 1
        assigns(:records)[0][:category].should == @cat
        assigns(:records)[0][:end_timestamp].hour.should == 2
        assigns(:records)[1][:timestamp].hour.should == 2
        assigns(:records)[1][:category].should == @cat2
        assigns(:records)[2][:timestamp].hour.should == 3
        assigns(:records)[2][:end_timestamp].min.should == 30
        assigns(:records)[2][:category].size.should == 2
        assigns(:records)[3][:timestamp].hour.should == 4
        assigns(:records)[3][:category].should == nil
      end
      it "creates the entries" do
        time = Time.zone.now - 3.hours
        post :batch, commit: I18n.t('record.create'), row: { 0 => { record_category_id: @cat.id, timestamp: time, end_timestamp: Time.zone.now - 1.hour } }
        flash[:notice].should == I18n.t('record.batch')
        assigns(:created).first.timestamp.should be_within(1.minute).of(time)
      end
    end
    describe 'GET help' do
      it "displays the help" do
        get :help
      end
    end
  end
  context "when browsing a demo account" do
    before do
      @user = create(:user, :demo)
      @cat = create(:record_category, user: @user)
      @record = create(:record, record_category: @cat, user: @user, timestamp: Time.zone.now - 2.hours, end_timestamp: Time.zone.now - 1.hour)
      @private_record = create(:record, :private, record_category: @cat, user: @user, timestamp: Time.zone.now - 2.hours, end_timestamp: Time.zone.now - 1.hour)
    end
    describe 'GET index' do
      it "shows public records" do
        get :index
        assigns(:records).should include(@record)
        assigns(:records).should_not include(@private_record)
      end
    end
    describe 'GET show' do
      it "shows public records" do
        get :show, id: @record.id
        assigns(:record).should == @record
      end
      it "hides private records" do
        get :show, id: @private_record.id
        response.should be_redirect
      end
    end
  end
end
