require 'spec_helper'
describe Record do
  describe "#guess_time" do
    it "leaves no-time entries alone" do
      o = Record.guess_time("hello")
      o[0].should == "hello"
      o[1].should be_nil
    end
    it "deals with nil" do
      o = Record.guess_time(nil)
      o[0].should be_nil
      o[1].should be_nil
    end
    it "recognizes hh:mm string" do
      o = Record.guess_time("8:00 test")
      o[0].should == "test"
      o[1].hour.should == 8
    end
    it "recognizes string hh:mm" do
      o = Record.guess_time("test 8:00")
      o[0].should == "test"
      o[1].hour.should == 8
    end
  end
  describe '#prepare_graph' do
    before :each do
      @user = Factory(:user, :confirmed_at => Time.now)
      @cat = Factory(:record_category, :user => @user)
      @cat2 = Factory(:record_category, :user => @user)
      Factory(:record, :user => @user, :timestamp => Date.yesterday.midnight.in_time_zone + 7.hours, :end_timestamp => Date.yesterday.midnight.in_time_zone + 10.hours, :record_category => @cat) 
      Factory(:record, :user => @user, :timestamp => Date.yesterday.midnight.in_time_zone + 10.hours, :end_timestamp => Date.yesterday.midnight.in_time_zone + 11.hours, :record_category => @cat2) 
      Factory(:record, :user => @user, :timestamp => Date.yesterday.midnight.in_time_zone + 11.hours, :end_timestamp => Date.yesterday.midnight.in_time_zone + 12.hours, :record_category => @cat) 
    end
    it "tallies up the totals for categories" do
      @records = @user.records
      list = Record.prepare_totals(Date.yesterday..Date.today, @records)
      list[0][@cat.id][:duration].should == 4.hours
      list[0][@cat2.id][:duration].should == 1.hours
    end
  end
  describe "#split" do
    it "handles records entirely within a day" do
      user = Factory(:user, :confirmed_at => Time.now)
      record = Factory(:record, :user => user, :timestamp => Date.yesterday.midnight.in_time_zone + 7.hours, :end_timestamp => Date.yesterday.midnight.in_time_zone + 10.hours)
      record.split.should == [[record.timestamp, record.end_timestamp, record]]
    end
    it "handles records that cross one date boundary" do
      user = Factory(:user, :confirmed_at => Time.now)
      record = Factory(:record, :user => user, :timestamp => Date.yesterday.midnight.in_time_zone + 7.hours, :end_timestamp => Date.today.midnight.in_time_zone + 10.hours)
      record.split.should == [[record.timestamp, Date.today.midnight.in_time_zone, record], [Date.today.midnight.in_time_zone, record.end_timestamp, record]]
    end
    it "handles records that cross two date boundaries" do
      user = Factory(:user, :confirmed_at => Time.now)
      record = Factory(:record, :user => user, :timestamp => Date.yesterday.midnight.in_time_zone + 7.hours, :end_timestamp => Date.tomorrow.midnight.in_time_zone + 10.hours)
      record.split.should == [[record.timestamp, Date.today.midnight.in_time_zone, record], 
                              [Date.today.midnight.in_time_zone, Date.tomorrow.midnight.in_time_zone, record],
                              [Date.tomorrow.midnight.in_time_zone, record.end_timestamp, record]]
    end
  end
end
