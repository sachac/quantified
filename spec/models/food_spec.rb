require 'spec_helper'

describe Food do
  describe '#get_food' do
    it 'creates new food' do
      expect(Food.get_food(FactoryGirl.create(:user), 'cabbage').name).to eq 'cabbage'
    end
    it 'returns existing food with exact name match' do
      u = FactoryGirl.create(:user)
      c = Food.get_food(u, 'cabbage')
      expect(c.name).to eq 'cabbage'
      expect(Food.get_food(u, 'cabbage')).to eq c
    end
    it 'returns existing food with singular search' do
      u = FactoryGirl.create(:user)
      c = Food.get_food(u, 'cabbages')
      expect(c.name).to eq 'cabbages'
      expect(Food.get_food(u, 'cabbage')).to eq c
    end
    it 'returns existing food with plural' do
      u = FactoryGirl.create(:user)
      c = Food.get_food(u, 'cabbage')
      expect(c.name).to eq 'cabbage'
      expect(Food.get_food(u, 'cabbages')).to eq c
    end
  end
  it "exports to CSV" do
    c = FactoryGirl.create(:food, name: 'cabbage')
    expect(c.to_comma).to eq [c.id.to_s,
                          'cabbage',
                          nil]
  end
end
