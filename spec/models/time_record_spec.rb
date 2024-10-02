require 'rails_helper'

describe TimeRecord do
  it "renames starts_at" do
    x = Time.zone.now.midnight
    expect(FactoryGirl.create(:time_record, start_time: x).starts_at).to eq x
  end
  it "renames ends_at" do
    x = Time.zone.now.midnight
    expect(FactoryGirl.create(:time_record, end_time: x).ends_at).to eq x
  end
  it "fixes category names" do
    expect(FactoryGirl.create(:time_record, name: 'A - Work').category).to eq 'Work'
    expect(FactoryGirl.create(:time_record, name: 'A - Sleep').category).to eq 'Sleep'
    expect(FactoryGirl.create(:time_record, name: 'D - Gardening').category).to eq 'Discretionary'
    expect(FactoryGirl.create(:time_record, name: 'UW - Tidy up').category).to eq 'Unpaid work'
    expect(FactoryGirl.create(:time_record, name: 'P - Routines').category).to eq 'Personal care'
  end
end
