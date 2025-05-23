require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  context "when anonymous" do
    subject { Ability.new(nil) }
    it "cannot manage users" do
      subject.should_not be_able_to(:manage, User)
    end
    it { should_not be_able_to(:create, Stuff) }
    it "can access demo info" do
      demo = FactoryGirl.build_stubbed(:demo_user)
      subject.should be_able_to(:view_dashboard, demo)
    end
    it "cannot access other users' info" do
      user0 = FactoryGirl.build_stubbed(:user)
      user = FactoryGirl.build_stubbed(:user)
      subject.should_not be_able_to(:view_dashboard, user)
    end
    it "can't view private notes" do
      user = FactoryGirl.build_stubbed(:demo_user)
      record = FactoryGirl.build_stubbed(:tap_log_record, user: user, note: 'blah blah !private blah')
      subject.should_not be_able_to(:view_note, record)
    end
    it "can view public demo notes" do
      user = FactoryGirl.build_stubbed(:demo_user)
      record = FactoryGirl.build_stubbed(:tap_log_record, user: user, note: 'blah blah blah')
      subject.should be_able_to(:view_note, record)
    end
  end
  context "when administrator" do
    subject { Ability.new(FactoryGirl.build_stubbed(:admin)) }
    it { should be_able_to(:manage, User) }
    it "can access other users' info" do
      user = FactoryGirl.build_stubbed(:user)
      subject.should be_able_to(:view_dashboard, user)
      subject.should be_able_to(:manage, :all)
    end
  end
  context "when a confirmed user" do
    before :each do
      DatabaseCleaner.start
      @user = FactoryGirl.build_stubbed(:confirmed_user)
    end
    subject { Ability.new(@user) }
    it { should be_able_to(:manage_account, @user) }
    it { should_not be_able_to(:manage, User) }
    it { should be_able_to(:create, Stuff) }
    it "can access own info" do
      subject.should be_able_to(:view_dashboard, @user) 
    end
    it "can access demo info" do
      demo = FactoryGirl.build_stubbed(:demo_user)
      subject.should be_able_to(:view_dashboard, demo)
    end
    it "can't view private demo notes" do
      user = FactoryGirl.build_stubbed(:demo_user)
      record = FactoryGirl.build_stubbed(:tap_log_record, user: user, note: 'blah blah !private blah')
      subject.should_not be_able_to(:view_note, record)
    end
    it "can view public demo notes" do
      user = FactoryGirl.build_stubbed(:demo_user)
      record = FactoryGirl.build_stubbed(:tap_log_record, user: user, note: 'blah blah blah')
      subject.should be_able_to(:view_note, record)
    end
    it "can't view other users' private notes" do
      user = FactoryGirl.build_stubbed(:user)
      record = FactoryGirl.build_stubbed(:tap_log_record, user: user, note: 'blah blah private blah')
      subject.should_not be_able_to(:view_note, record)
    end
    it "can view own private notes" do
      record = FactoryGirl.build_stubbed(:tap_log_record, user: @user, note: 'blah blah private blah')
      subject.should be_able_to(:view_note, record)
    end
  end
end
