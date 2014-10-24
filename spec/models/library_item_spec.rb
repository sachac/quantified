require 'spec_helper'

describe LibraryItem do
  before do
    Timecop.freeze(2014, 10, 22)
    @u = FactoryGirl.create(:user)
    @i1 = FactoryGirl.create(:library_item, user: @u, status: 'due', due: Time.zone.today, public: true, library_id: '12345', title: 'Hello world', author: 'Joe Schmoe', checkout_date: Time.zone.now.yesterday)
    @i2 = FactoryGirl.create(:library_item, user: @u, status: 'due', due: Time.zone.today, public: false)
    @i3 = FactoryGirl.create(:library_item, user: @u, status: 'returned', due: Time.zone.today, public: true)
  end
  after do
    Timecop.return
  end
  it "keeps track of current items" do
    expect(LibraryItem.current_items(@u)).to eq [@i1, @i2]
  end
  it "keeps track of current public items" do
    expect(LibraryItem.current_items(@u, true)).to eq [@i1]
  end
  it "exports to CSV" do
    @i1.to_comma.should == ['12345', 'Hello world', 'Joe Schmoe', 'due', '2014-10-21', '2014-10-22', nil, nil, nil, nil, 'true', nil, nil]
  end
end
