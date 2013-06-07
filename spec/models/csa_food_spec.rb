require 'spec_helper'

describe CsaFood do
  describe '#log' do
    context 'when food is specified as an object' do
      it 'uses that object' do
        u = FactoryGirl.create(:user)
        CsaFood.log(u, food: FactoryGirl.create(:food, user: u, name: 'cabbage'), quantity: 5, date_received: Time.zone.today)
        u.csa_foods.sum(:quantity).should == 5
      end
    end
    context 'when food is specified as a string' do
      it 'creates the food if needed' do
        u = FactoryGirl.create(:user)
        CsaFood.log(u, food: 'cabbage', quantity: 5, date_received: Time.zone.today)
        u.csa_foods.sum(:quantity).should == 5
      end
    end
    context 'when updating previous entry' do
      it 'replaces the old value' do
        u = FactoryGirl.create(:user)
        f = FactoryGirl.create(:food, user: u, name: 'cabbage')
        log1 = CsaFood.log(u, food: f, quantity: 5, date_received: Time.zone.now.yesterday.to_date)
        log2 = CsaFood.log(u, food: f, quantity: 6, date_received: Time.zone.now.yesterday.to_date)
        u.csa_foods.sum(:quantity).should == 11
        u.csa_foods.size.should == 1
      end
    end
  end
  describe 'exports' do
    before(:each) do
      @u = FactoryGirl.create(:user)
      @entry = CsaFood.log(@u, food: 'cabbage', quantity: 5, date_received: Time.zone.today)
    end
    it 'exports to CSV' do
      @entry.to_comma.should == [@entry.id.to_s,
                                 Time.zone.today.to_s,
                                 @entry.food_id.to_s,
                                 'cabbage',
                                 '5',
                                 '',
                                 '',
                                 '']
    end
    it 'exports to XML' do 
      @entry.to_xml.should match 'cabbage'
    end
    it 'exports to JSON' do 
      @entry.to_json.should match 'cabbage'
    end
  end
end
