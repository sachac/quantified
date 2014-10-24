require 'spec_helper'

describe Memory do
  describe '#parse_date' do
    it "understands yyyy-mm-dd" do
      expect(Memory.parse_date('2013-01-02').to_date).to eq Time.zone.local(2013, 1, 2).to_date
    end
    it "understands yyyy" do
      expect(Memory.parse_date('2011').to_date).to eq Time.zone.local(2011, 1, 1).to_date
    end
    it "understands yyyy-mm" do
      expect(Memory.parse_date('2011-05').to_date).to eq Time.zone.local(2011, 5, 1).to_date
    end
    it "handles problems gracefully" do
      expect(Memory.parse_date('Some time ago').to_date).to eq Time.zone.local(Time.zone.today.year, 1, 1).to_date
    end
  end

  context 'private' do
    subject { FactoryGirl.create(:memory, access: 'private') }
    it { should be_private }
    it { should_not be_public }
  end
end
