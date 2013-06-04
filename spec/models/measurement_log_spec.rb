require 'spec_helper'

describe MeasurementLog do
  before(:each) do
    @m = FactoryGirl.create(:measurement)
    u = @m.user
    FactoryGirl.create(:measurement_log, measurement: @m, value: 1)
    FactoryGirl.create(:measurement_log, measurement: @m, value: 3)
    FactoryGirl.create(:measurement_log, measurement: @m, value: 5)
    @m.reload
  end
  it "updates the measurement minimum" do @m.min.should == 1 end
  it "updates the measurement maximum" do @m.max.should == 5 end
  it "updates the measurement average" do @m.average.should == 3 end
  it "updates the measurement sum" do @m.sum.should == 9 end
end
