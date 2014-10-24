require 'spec_helper'

describe CsaFood do
  describe '#log' do
    context 'when food is specified as an object' do
      it 'uses that object' do
        u = FactoryGirl.create(:user)
        CsaFood.log(u, food: FactoryGirl.create(:food, user: u, name: 'cabbage'), quantity: 5, date_received: Time.zone.today)
        expect(u.csa_foods.sum(:quantity)).to eq 5
      end
    end
    context 'when food is specified as a string' do
      it 'creates the food if needed' do
        u = FactoryGirl.create(:user)
        CsaFood.log(u, food: 'cabbage', quantity: 5, date_received: Time.zone.today)
        expect(u.csa_foods.sum(:quantity)).to eq 5
      end
    end
    context 'when updating previous entry' do
      it 'replaces the old value' do
        u = FactoryGirl.create(:user)
        f = FactoryGirl.create(:food, user: u, name: 'cabbage')
        log1 = CsaFood.log(u, food: f, quantity: 5, date_received: Time.zone.now.yesterday.to_date)
        log2 = CsaFood.log(u, food: f, quantity: 6, date_received: Time.zone.now.yesterday.to_date)
        expect(u.csa_foods.sum(:quantity)).to eq 11
        expect(u.csa_foods.size).to eq 1
      end
    end
  end
  describe 'exports' do
    before(:each) do
      @u = FactoryGirl.create(:user)
      @entry = CsaFood.log(@u, food: 'cabbage', quantity: 5, date_received: Time.zone.today)
    end
    it 'exports to CSV' do
      expect(@entry.to_comma).to eq [@entry.id.to_s,
                                 Time.zone.today.to_s,
                                 @entry.food_id.to_s,
                                 'cabbage',
                                 '5',
                                 nil,
                                 nil,
                                 nil]
    end
    it 'exports to XML' do 
      expect(@entry.to_xml).to match 'cabbage'
    end
    it 'exports to JSON' do 
      expect(@entry.to_json).to match 'cabbage'
    end
  end
end
