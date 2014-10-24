require 'spec_helper'
describe Day do
  describe 'static methods' do
    it "can navigate to yesterday" do
      user = FactoryGirl.build_stubbed(:confirmed_user)
      expect(Day.yesterday(user).date).to eq Time.zone.today.yesterday.to_date
    end
    it "can navigate to today" do
      user = FactoryGirl.build_stubbed(:confirmed_user)
      expect(Day.today(user).date).to eq Time.zone.today
    end
  end
end
