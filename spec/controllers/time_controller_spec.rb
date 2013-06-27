require 'spec_helper'

describe TimeController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when logged in" do
    before do
      @user = create(:user, :confirmed)
      @cat = create(:record_category, user: @user)
      @records = Array.new
      @records << create(:record, user: @user, record_category: @cat,
                         timestamp: Time.zone.local(2013, 1, 1, 3),
                         end_timestamp: Time.zone.local(2013, 1, 1, 4))
      @records << create(:record, user: @user, record_category: @cat,
                         timestamp: Time.zone.local(2013, 1, 1, 4),
                         end_timestamp: Time.zone.local(2013, 1, 1, 5))
      @records << create(:record, user: @user, record_category: @cat,
                         timestamp: Time.zone.now - 2.days,
                         end_timestamp: Time.zone.now - 2.days + 1.hour)
      @records << create(:record, user: @user, record_category: @cat, timestamp: Time.zone.now - 1.hour)
      sign_in @user
    end
    describe 'POST refresh_from_csv' do
      it "refreshes based on the CSV" do
        file = fixture_file_upload('/files/sample-tap-log.csv', 'text/csv')
        # http://stackoverflow.com/questions/7793510/mocking-file-uploads-in-rails-3-1-controller-tests
        class << file
          # The reader method is present in a real invocation,
          # but missing from the fixture object for some reason (Rails 3.1.1)
          attr_reader :tempfile
        end
        post :refresh_from_csv, tap_file: file
        flash[:notice].should == I18n.t('time.refreshed')
        Record.count.should > 3                                    
      end      
    end
    describe 'GET refresh' do
      it "displays the refresh page" do
        get :refresh
      end
    end
    describe 'GET review' do
      it "displays records" do
        get :review, start: Time.zone.now - 1.week, end: Time.zone.now - 1.day
        assigns(:zoom).should == :daily
        assigns(:summary)['rows'][@cat.id]['total'].should == 3600
      end
    end
    describe 'GET graph' do
      it "displays records" do
        get :graph, start: Time.zone.now - 1.week, end: Time.zone.now.midnight
        assigns(:categories).values.should include(@cat)
        assigns(:totals)[1][0].should == @cat.id
        assigns(:totals)[1][1].should == [[:total, 3600]]
      end
    end
    describe 'GET dashboard' do
      it "shows the dashboard" do
        get :dashboard
        assigns(:categories).values.should include(@cat)
        assigns(:current_activity).should == @records[3]
      end
    end
    describe 'POST track' do
      it "requires a category or category ID" do
        post :track
        response.should redirect_to time_dashboard_path
      end
      it "handles timestamp if given" do
        time = Time.zone.local(2013, 1, 1, 3)
        post :track, timestamp: time, category_id: @cat.id
        assigns(:time).should be_within(1.minute).of(time)
      end
      it "offers to create a category if necessary" do
        post :track, category: "Does not exist"
        flash[:notice].should == I18n.t('record_category.not_found_create')
      end
      it "creates the entry if unambiguous" do
        last = Record.last
        post :track, category: @cat.name
        Record.last.should_not == last
      end
      it "redirects if ambiguous" do
        create(:record_category, user: @user, name: @cat.name + "X")
        last = Record.last
        post :track, category: @cat.name
        Record.last.should == last
        response.should be_redirect
      end
    end
  end
end
