require 'rails_helper'
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
      expect(stuff.distinct_locations.to_a.size).to eq 2
    end
  end

  describe '#hierarchy' do
    it 'returns the location hierarchy for this stuff' do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, name: 'Location1', user: stuff.user)
      stuff.save
      stuff.location.location = FactoryGirl.create(:stuff, name: 'Location', user: stuff.user)
      stuff.location.save
      expect(stuff.reload.hierarchy).to eq [stuff.location, stuff.location.location]
    end

    it 'does not get confused by loops' do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, name: 'Location1', user: stuff.user)
      stuff.save
      stuff.location.location = FactoryGirl.create(:stuff, name: 'Location', user: stuff.user)
      stuff.location.save
      stuff.location.location.location = stuff.location
      stuff.location.location.save
      expect(stuff.reload.hierarchy).to eq [stuff.location, stuff.location.location]
    end

    it 'stops at locations' do
      stuff = FactoryGirl.create(:stuff)
      stuff.location = FactoryGirl.create(:stuff, name: 'Location1', user: stuff.user)
      stuff.save
      stuff.location.location = nil
      stuff.location.save
      expect(stuff.reload.hierarchy).to eq [stuff.location]
    end
  end

  describe '#bulk_update' do
    it 'saves locations' do
      loc = FactoryGirl.create(:stuff, name: 'Secret Lair')
      backpack = FactoryGirl.create(:stuff, name: 'Backpack', user: loc.user)
      results = Stuff.bulk_update(loc.user, loc.name, "backpack\nwallet")
      expect(loc.user.stuff.where(name: 'backpack').first.location).to eq loc
      expect(loc.user.stuff.where(name: 'wallet').first.location).to eq loc
      expect(results[:success].size).to eq 2
    end
    it 'handles errors' do
      loc = FactoryGirl.create(:stuff, name: 'Secret Lair')
      backpack = FactoryGirl.create(:stuff, name: 'Backpack', user: loc.user)
      allow_any_instance_of(Stuff).to receive(:save).and_return(false)
      results = Stuff.bulk_update(loc.user, loc.name, "backpack\nwallet")
      expect(results[:failure]).to eq ['backpack', 'wallet']
    end
  end

  describe '#find_or_create' do
    it "finds existing stuff" do
      stuff = FactoryGirl.create(:stuff)
      expect(Stuff.find_or_create(stuff.user, stuff.name)).to eq stuff
    end
    it "creates stuff if needed" do
      expect(Stuff.find_or_create(FactoryGirl.create(:user), 'newstuff').name).to eq 'newstuff'
    end
  end

  describe 'export' do
    before(:each) do 
      @user = FactoryGirl.create(:user)
      @loc = FactoryGirl.create(:stuff, user: @user, name: 'Weapons box')
      @stuff = FactoryGirl.create(:stuff, user: @user, name: 'Rocket launcher', long_name: "Deluxe rocket launcher", home_location: @loc, location: @loc, price: 0, notes: 'notes go here')
    end
    
    it 'converts to CSV' do
      expect(@stuff.to_comma).to eq [@stuff.id.to_s,
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
      expect(@stuff.to_xml).to match /home-location-name/
      expect(@stuff.to_xml).to match /Weapons box/
    end

    it 'converts to JSON' do
      expect(@stuff.to_json).to match /home_location_name/
      expect(@stuff.to_json).to match /Weapons box/
    end
  end
end
