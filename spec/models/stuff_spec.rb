require 'spec_helper'
describe Stuff do
  before(:each) do
  end

  describe '#distinct_locations' do
    it "returns only distinct locations" do
      stuff = FactoryGirl.create(:stuff)
      location1 = stuff.location = FactoryGirl.create(:stuff, user: stuff.user)
      stuff.save
      location2 = stuff.location = FactoryGirl.create(:stuff, user: stuff.user)
      stuff.save
      stuff.location = location1
      stuff.location.save
      stuff2 = FactoryGirl.create(:stuff, user: stuff.user)
      stuff.distinct_locations.all.size.should == 2
    end
  end

  describe '#hierarchy' do
    it 'returns the location hierarchy for this stuff' do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, name: 'Location1', user: stuff.user)
      stuff.save
      stuff.location.location = FactoryGirl.create(:stuff, name: 'Location', user: stuff.user)
      stuff.location.save
      stuff.reload.hierarchy.should == [stuff.location, stuff.location.location]
    end

    it 'does not get confused by loops' do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, name: 'Location1', user: stuff.user)
      stuff.save
      stuff.location.location = FactoryGirl.create(:stuff, name: 'Location', user: stuff.user)
      stuff.location.save
      stuff.location.location.location = stuff.location
      stuff.location.location.save
      stuff.reload.hierarchy.should == [stuff.location, stuff.location.location]
    end

    it 'stops at locations' do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, name: 'Location1', user: stuff.user)
      stuff.save
      stuff.location.location = nil
      stuff.location.save
      stuff.reload.hierarchy.should == [stuff.location]
    end
  end

  describe '#bulk_update' do
    it 'saves locations' do
      loc = FactoryGirl.create(:stuff, name: 'Secret Lair')
      backpack = FactoryGirl.create(:stuff, name: 'Backpack', user: loc.user)
      results = Stuff.bulk_update(loc.user, loc.name, "backpack\nwallet")
      loc.user.stuff.where(name: 'backpack').first.location.should == loc
      loc.user.stuff.where(name: 'wallet').first.location.should == loc
      results[:success].size.should == 2
    end
    it 'handles errors' do
      loc = FactoryGirl.create(:stuff, name: 'Secret Lair')
      backpack = FactoryGirl.create(:stuff, name: 'Backpack', user: loc.user)
      Stuff.any_instance.stub(:save).and_return(false)
      results = Stuff.bulk_update(loc.user, loc.name, "backpack\nwallet")
      results[:failure].should == ['backpack', 'wallet']
    end
  end

  describe '#find_or_create' do
    it "finds existing stuff" do
      stuff = FactoryGirl.create(:stuff)
      Stuff.find_or_create(stuff.user, stuff.name).should == stuff
    end
    it "creates stuff if needed" do
      Stuff.find_or_create(FactoryGirl.create(:user), 'newstuff').name.should == 'newstuff'
    end
  end

  describe 'export' do
    before(:each) do 
      @user = FactoryGirl.create(:user)
      @loc = FactoryGirl.create(:stuff, user: @user, name: 'Weapons box')
      @stuff = FactoryGirl.create(:stuff, user: @user, name: 'Rocket launcher', long_name: "Deluxe rocket launcher", home_location: @loc, location: @loc, price: 0, notes: 'notes go here')
    end
    
    it 'converts to CSV' do
      @stuff.to_comma.should == [@stuff.id.to_s,
                                 'Rocket launcher',
                                 'Deluxe rocket launcher',
                                 'true',
                                 @loc.id.to_s,
                                 'Weapons box',
                                 @loc.id.to_s,
                                 'Weapons box',
                                 '0',
                                 'notes go here']
    end
    it 'converts to XML' do
      @stuff.to_xml.should match /home-location-name/
      @stuff.to_xml.should match /Weapons box/
    end

    it 'converts to JSON' do
      @stuff.to_json.should match /home_location_name/
      @stuff.to_json.should match /Weapons box/
    end
  end
end
