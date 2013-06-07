require 'spec_helper'

describe TimeRecord do
  it "renames starts_at" do
    x = Time.zone.now.midnight
    FactoryGirl.create(:time_record, start_time: x).starts_at.should == x
  end
  it "renames ends_at" do
    x = Time.zone.now.midnight
    FactoryGirl.create(:time_record, end_time: x).ends_at.should == x
  end
  it "fixes category names" do
    FactoryGirl.create(:time_record, name: 'A - Work').category.should == 'Work'
    FactoryGirl.create(:time_record, name: 'A - Sleep').category.should == 'Sleep'
    FactoryGirl.create(:time_record, name: 'D - Gardening').category.should == 'Discretionary'
    FactoryGirl.create(:time_record, name: 'UW - Tidy up').category.should == 'Unpaid work'
    FactoryGirl.create(:time_record, name: 'P - Routines').category.should == 'Personal care'
  end
end
