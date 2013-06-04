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
    it "recognizes -30min" do
      o = Record.guess_time("test 8:00 -30min")
      o[0].should == "test"
      o[1].hour.should == 7
      o[1].min.should == 30
    end
    it "recognizes m/d" do
      o = Record.guess_time("test 8:00 1/1")
      o[0].should == "test"
      o[1].month.should == 1
      o[1].day.should == 1
    end
  end
  describe '#create_batch' do
    it "creates unambiguous records" do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user, :name => 'ABCX')
      @cat2 = FactoryGirl.create(:record_category, :user => @user, :name => 'XYZ')
      lines = <<END
7:30 ABC
8:30 XYZ
9:30 X
10:00 J
END
      out = Record.confirm_batch(@user, lines)
      Record.create_batch(@user, out)
      @user.records.length.should == 2
    end
  end

  describe '#confirm_batch' do
    it "parses lines" do 
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user, :name => 'ABCX')
      @cat2 = FactoryGirl.create(:record_category, :user => @user, :name => 'XYZ')
      lines = <<END
7:30 ABC
8:30 XYZ
9:30 X
10:00 J
END
      out = Record.confirm_batch(@user, lines)
      out.length.should == 4
      out[0][:timestamp].hour.should == 7
      out[0][:timestamp].min.should == 30
      out[0][:text].should == "7:30 ABC"
      out[0][:category].should == @cat
      out[1][:timestamp].hour.should == 8
      out[1][:timestamp].min.should == 30
      out[1][:category].should == @cat2
      out[2][:category].length.should == 2
      out[3][:category].should be_nil
    end
    def confirm_batch(account, lines)
      if lines.is_a? String
        lines = lines.split /[\r\n]+/
      end
      lines.map do |line|
        # See if we need to disambiguate them
        { :time => Record.guess_time(line), :category => RecordCategory.search(account, line), :text => line }
      end
    end

  end

  describe "#split" do
    it "handles records entirely within a day" do
      user = FactoryGirl.create(:confirmed_user)
      record = FactoryGirl.create(:record, :user => user, :timestamp => Time.zone.now.midnight - 1.day + 7.hours, :end_timestamp => Time.zone.now.midnight - 1.day + 10.hours)
      record.split.should == [[record.timestamp, record.end_timestamp, record]]
    end
    it "handles records that cross one date boundary" do
      user = FactoryGirl.create(:confirmed_user)
      record = FactoryGirl.create(:record, :user => user, :timestamp => Time.zone.now.midnight - 1.day + 7.hours, :end_timestamp => Time.zone.now.midnight + 10.hours)
      record.split.should == [[record.timestamp, Time.zone.now.midnight, record], [Time.zone.now.midnight, record.end_timestamp, record]]
    end
    it "handles records that cross two date boundaries" do
      user = FactoryGirl.create(:confirmed_user)
      record = FactoryGirl.create(:record, :user => user, :timestamp => Time.zone.now.midnight - 1.day + 7.hours, :end_timestamp => Time.zone.now.midnight + 1.day + 10.hours)
      record.split.should == [[record.timestamp, Time.zone.now.midnight.in_time_zone, record], 
                              [Time.zone.now.midnight, Time.zone.now.midnight + 1.day, record],
                              [Time.zone.now.midnight + 1.day, record.end_timestamp, record]]
    end
  end

  describe '#prepare_graph' do
    it "splits by date" do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user)
      @cat2 = FactoryGirl.create(:record_category, :user => @user)
      FactoryGirl.create(:record, :user => @user, :timestamp => Time.zone.now.midnight - 2.hours, 
                         :end_timestamp => Time.zone.now.midnight + 1.hour, :record_category => @cat) 
      @records = @user.records
      range = (Time.zone.now.to_date - 1.day)..(Time.zone.now.to_date + 1.day)
      list = Record.prepare_graph(range, @records)
      (list[0][0][1] - list[0][0][0]).should == 2.hours
      (list[1][0][1] - list[1][0][0]).should == 1.hour
    end
  end
end
