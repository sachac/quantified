require 'spec_helper'

describe TapLogRecord do
  describe '#time_category' do
    it 'recognizes discretionary' do
      FactoryGirl.create(:tap_log_record, catOne: 'Discretionary', catTwo: 'Relax').time_category.should == 'D - Relax'
    end
    it 'recognizes personal' do
      FactoryGirl.create(:tap_log_record, catOne: 'Personal', catTwo: 'Routines').time_category.should == 'P - Routines'
    end
    it 'recognizes unpaid work' do
      FactoryGirl.create(:tap_log_record, catOne: 'Unpaid work', catTwo: 'Cooking').time_category.should == 'UW - Cooking'
    end
    it 'recognizes work' do
      FactoryGirl.create(:tap_log_record, catOne: 'Work').time_category.should == 'A - Work'
    end
    it 'recognizes sleep' do
      FactoryGirl.create(:tap_log_record, catOne: 'Sleep').time_category.should == 'A - Sleep'
    end
  end
  describe '#to_s' do
    subject { FactoryGirl.create(:tap_log_record, catOne: 'Sleep', timestamp: Time.zone.parse('2013-02-01 11:00')).to_s }
    it { should match "2013-02-01" }
    it { should match "A - Sleep" }
    it { should match "\tSleep\t" }
  end
  describe '#category_string' do
    it "should concatenate categories" do
      record = FactoryGirl.create(:tap_log_record, catOne: 'Unpaid work', catTwo: 'Cooking')
      record.category_string.should == 'Unpaid work > Cooking'
    end
  end
  describe '#private?' do
    it 'recognizes private notes' do
      record = FactoryGirl.create(:tap_log_record, catOne: 'Unpaid work', catTwo: 'Cooking', note: 'blah blah !private blah')
      record.should be_private 
    end
    it 'recognizes public notes' do
      record = FactoryGirl.create(:tap_log_record, catOne: 'Unpaid work', catTwo: 'Cooking', note: 'blah blah blah')
      record.should_not be_private
    end
  end
  describe '#current_activity' do
    context 'when this is an activity' do
      it "detects the current activity" do
        record = FactoryGirl.create(:tap_log_record, entry_type: 'activity', catOne: 'Sleep')
        record.current_activity.should == record
      end
    end
    context 'when this is a record' do
      it "detects the current activity" do
        user = FactoryGirl.create(:confirmed_user)
        old = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', timestamp: Time.now - 1.day, catOne: 'Work', catTwo: 'Office')
        activity = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', catOne: 'Sleep', timestamp: Time.now - 1.hour)
        record = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'record', catOne: 'Text', timestamp: Time.now)
        record.current_activity.should == activity
      end
    end
  end
  describe '#during_this' do
    it "identifies records inside an activity with no ending timestamp" do
      user = FactoryGirl.create(:confirmed_user)
      activity = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', catOne: 'Sleep', timestamp: Time.now - 1.hour)
      record = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'record', catOne: 'Text', timestamp: Time.now)
      activity.during_this.should == [record]
    end
    it "identifies records inside an activity with an ending timestamp" do
      user = FactoryGirl.create(:confirmed_user)
      activity = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', catOne: 'Sleep', timestamp: Time.now - 1.hour, end_timestamp: Time.now - 30.minutes)
      record = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'record', catOne: 'Text', timestamp: Time.now - 45.minutes)
      record2 = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'record', catOne: 'Text', timestamp: Time.now)
      activity.during_this.should == [record]
    end
  end
  describe '#previous' do 
    it 'knows when there is a previous activity' do
      user = FactoryGirl.create(:confirmed_user)
      old = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', timestamp: Time.now - 1.day, catOne: 'Work', catTwo: 'Office')
      activity = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', catOne: 'Sleep')
      activity.previous.should == [old]
    end
    it 'knows when there is no previous activity' do
      activity = FactoryGirl.create(:tap_log_record,  entry_type: 'activity', catOne: 'Sleep')
      activity.previous.should == []
    end
  end
  describe '#next' do 
    it 'knows when there is a next activity' do
      user = FactoryGirl.create(:confirmed_user)
      old = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', timestamp: Time.now - 1.day, catOne: 'Work', catTwo: 'Office')
      activity = FactoryGirl.create(:tap_log_record, user: user, entry_type: 'activity', catOne: 'Sleep')
      old.next.should == [activity]
    end
    it 'knows when there is no next activity' do
      activity = FactoryGirl.create(:tap_log_record, entry_type: 'activity', catOne: 'Sleep')
      activity.next.should == []
    end
  end

end
