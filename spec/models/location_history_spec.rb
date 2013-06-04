require 'spec_helper'

describe LocationHistory do
  context "when stuff changes location" do
    before :each do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, user: stuff.user)
      stuff.save!
    end
    describe '#to_xml' do
      subject { LocationHistory.last.to_xml }
      it { should match 'stuff-name' }
      it { should match 'location-name' }
    end
    describe '#to_json' do
      subject { LocationHistory.last.to_json }
      it { should match 'stuff_name' }
      it { should match 'location_name' }
    end
    it 'exports to CSV' do
      l = LocationHistory.last
      l.to_comma.should == [l.datetime.to_s, l.stuff_id.to_s, l.stuff_name, l.location_id.to_s, l.location_name, ""]
    end
  end

end
