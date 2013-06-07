require 'spec_helper'

describe Food do
  describe '#get_food' do
    it 'creates new food' do
      Food.get_food(FactoryGirl.create(:user), 'cabbage').name.should == 'cabbage'
    end
    it 'returns existing food with exact name match' do
      u = FactoryGirl.create(:user)
      c = Food.get_food(u, 'cabbage')
      c.name.should == 'cabbage'
      Food.get_food(u, 'cabbage').should == c
    end
    it 'returns existing food with singular search' do
      u = FactoryGirl.create(:user)
      c = Food.get_food(u, 'cabbages')
      c.name.should == 'cabbages'
      Food.get_food(u, 'cabbage').should == c
    end
    it 'returns existing food with plural' do
      u = FactoryGirl.create(:user)
      c = Food.get_food(u, 'cabbage')
      c.name.should == 'cabbage'
      Food.get_food(u, 'cabbages').should == c
    end
  end
  it "exports to CSV" do
    c = FactoryGirl.create(:food, name: 'cabbage')
    c.to_comma.should == [c.id.to_s,
                          'cabbage',
                          '']
  end
end
