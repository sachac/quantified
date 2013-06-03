require 'spec_helper'
require "cancan/matchers"

describe Ability do
  context "when anonymous" do
    subject { Ability.new(nil) }
    it { should_not be_able_to(:manage, User) }
    it { should_not be_able_to(:create, Stuff) }
  end
  context "when an administrator" do
    subject { Ability.new(FactoryGirl.create(:admin)) }
    it { should be_able_to(:manage, User) }
  end
  context "allows confirmed users to change their own accounts" do
    subject { Ability.new(FactoryGirl.create(:confirmed_user)) }
    it { should_not be_able_to(:manage, User) }
    it { should be_able_to(:create, Stuff) }
  end
end
