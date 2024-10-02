require 'rails_helper'
include Warden::Test::Helpers

describe "Time", :type => :request do
  describe "GET /time/review" do
    before :each do
      @user = create(:user, :confirmed)
      login_as @user, scope: :user
      %w(Sleep Routines Work Relax).each { |x| create(:record_category, user: @user, name: x) }
      input =<<-EOF
      0:00 8:00 Sleep
      8:00 9:30 Routines
      9:30 17:00 Work
      17:00 21:00 Relax
      21:00 22:00 Routines
      EOF
      @records = Record.create_batch(@user, Record.confirm_batch(@user, input, date: '2014-01-31'))
      Record.create_batch(@user, Record.confirm_batch(@user, input, date: '2014-01-30'))
      Record.parse(@user, category: '2014-01-30 22:00 Sleep')
      Record.parse(@user, category: '2014-01-31 22:00 Sleep')
      
      Record.parse(@user, category: '2014-02-01 8:00 Routines')
      Record.parse(@user, category: '2014-02-01 9:00 Work')
    end
    context "Daily view" do
      before :each do
        @params = {:start => '2014-01-31', :end => '2014-02-01'}
      end
      it "should display percentages" do
        get '/time/review', @params.merge(:display_type => 'percentage')
        response.body.should include '10.4%' # for routines
      end
      it "should display time" do
        get '/time/review', @params.merge(:display_type => 'time')
        response.body.should include '2:30' # for routines
      end
      it "should display decimals" do
        get '/time/review', @params.merge(:display_type => 'decimal')
        response.body.should include '2.5' # for routines
      end
    end
    context "Monthly view" do
      before :each do
        @params = {:start => '2014-01-01', :end => '2014-02-01', :zoom_level => 'monthly'}
      end
      it "should display percentages" do
        get '/time/review', @params.merge(:display_type => 'percentage')
        response.body.should include '10.4%' # for routines
      end
      it "should display time" do
        get '/time/review', @params.merge(:display_type => 'time')
        response.body.should include '5:00' # for routines
      end
      it "should display decimals" do

        get '/time/review', @params.merge(:display_type => 'decimal')
        response.body.should include '5.0' # for routines
      end
    end
    context "Weekly view" do
      before :each do
        @params = {:start => '2014-01-01', :end => '2014-02-02', :zoom => 'monthly'}
      end
      it "should display percentages" do
        get '/time/review', @params.merge(:display_type => 'percentage')
        response.body.should include '10.4%' # for routines, first week
      end
      it "should display time" do
        get '/time/review', @params.merge(:display_type => 'time')
        response.body.should include '5:00' # for routines
        response.body.should include '6:00' # for routines including 2-1
      end
      it "should display decimals" do
        get '/time/review', @params.merge(:display_type => 'decimal')
        response.body.should include '6.0' # for routine total including 2-1
      end
    end
  end
end
