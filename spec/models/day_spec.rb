require 'spec_helper'
describe Day do
  describe 'static methods' do
    it "can navigate to yesterday" do
      user = FactoryGirl.create(:confirmed_user)
      Day.yesterday(user).date.should == Time.zone.today.yesterday.to_date
    end
    it "can navigate to today" do
      user = FactoryGirl.create(:confirmed_user)
      Day.today(user).date.should == Time.zone.today
    end
  end
end
