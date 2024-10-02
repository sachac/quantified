require 'rails_helper'
describe StuffObserver do
  it "watches for location changes" do
    stuff = FactoryGirl.create(:stuff)
    stuff.location = FactoryGirl.create(:stuff)
    stuff.save!
    LocationHistory.last.stuff.should == stuff
    LocationHistory.last.location.should == stuff.location
  end
end
