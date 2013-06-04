require 'spec_helper'

describe LibraryItem do
  before(:each) do 
    @u = FactoryGirl.create(:user)
    @i1 = FactoryGirl.create(:library_item, user: @u, status: 'due', due: Time.zone.today, public: true, library_id: '12345', title: 'Hello world', author: 'Joe Schmoe', checkout_date: Time.zone.now.yesterday)
    @i2 = FactoryGirl.create(:library_item, user: @u, status: 'due', due: Time.zone.today, public: false)
    @i3 = FactoryGirl.create(:library_item, user: @u, status: 'returned', due: Time.zone.today, public: true)
  end
  it "keeps track of current items" do
    LibraryItem.current_items(@u).should == [@i1, @i2]
  end
  it "keeps track of current public items" do
    LibraryItem.current_items(@u, true).should == [@i1]
  end
  it "exports to CSV" do
    @i1.to_comma.should == ['12345', 'Hello world', 'Joe Schmoe', 'due', Time.zone.now.yesterday.to_s, Time.zone.today.to_s, '', '', '', '', 'true', '', '']
  end
end
