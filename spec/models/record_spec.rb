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
end
