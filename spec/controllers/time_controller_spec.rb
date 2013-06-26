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
                         timestamp: Time.zone.now - 1.day,
                         end_timestamp: Time.zone.now - 1.day + 1.hour)
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
        get :review, start: Time.zone.now - 1.week, end: Time.zone.now
        assigns(:zoom).should == :daily
        assigns(:summary)['rows'][@cat.id]['total'].should == 3600
      end
    end
    describe 'GET graph' do
      it "displays records" do
        get :graph, start: Time.zone.now - 1.week, end: Time.zone.now
        assigns(:categories).values.should include(@cat)
        assigns(:totals)[1][0].should == @cat.id
        assigns(:totals)[1][1].should == [[:total, 3600]]
      end
    end
  end
end
