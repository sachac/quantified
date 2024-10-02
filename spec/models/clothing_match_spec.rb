require 'rails_helper'

describe ClothingMatch do
  before(:each) do
    clothing = FactoryGirl.create(:clothing)
    match = FactoryGirl.create(:clothing, user: clothing.user)
    match2 = FactoryGirl.create(:clothing, user: clothing.user)
    FactoryGirl.create(:clothing_log, clothing: clothing, date: Time.zone.today - 1.day, user: clothing.user)
    FactoryGirl.create(:clothing_log, clothing: match, date: Time.zone.today - 1.day, user: clothing.user)
    FactoryGirl.create(:clothing_log, clothing: clothing, date: Time.zone.today - 2.days, user: clothing.user)
    FactoryGirl.create(:clothing_log, clothing: match2, date: Time.zone.today - 1.day, user: clothing.user)
    @clothing = clothing
  end
  
  describe '.recreate' do
    it 'recreates clothing matches for an item of clothing' do
      ClothingMatch.recreate(@clothing)
      @clothing.clothing_matches.size.should == 2
    end
  end
  describe '.delete_matches' do
    it 'clears all matches for clothing' do
      ClothingMatch.delete_matches(@clothing)
      @clothing.reload.clothing_matches.size.should == 0
    end
  end
  describe '.flush' do
    it 'recreates everything' do
      ClothingMatch.flush
      @clothing.clothing_matches.size.should == 2
    end
  end
  it "converts to XML" do
    match = @clothing.clothing_matches.first
    match.to_xml.should match match.clothing_a.name
  end
  it "converts to JSON" do
    match = @clothing.clothing_matches.first
    match.to_json.should match match.clothing_a.name
  end
  it "converts to CSV" do
    match = @clothing.clothing_matches.first
    match.to_comma.should == [match.user_id.to_s,
                              (Time.zone.today - 1.day).to_s,
                              match.clothing_log_a_id.to_s,
                              @clothing.id.to_s,
                              @clothing.name,
                              match.clothing_log_b_id.to_s,
                              match.clothing_b.id.to_s,
                              match.clothing_b.name.to_s]
  end

  describe '.prepare_graph' do
    before do
      @u = create(:user, :confirmed)
      @clothes = Array.new
      6.times do 
        @clothes << create(:clothing, user: @u)
      end
      create(:clothing, user: create(:user, :confirmed)) # should not be included
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 1), clothing: @clothes[0])
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 1), clothing: @clothes[1])
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 1), clothing: @clothes[2], outfit_id: 2)
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 1), clothing: @clothes[3], outfit_id: 2)
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 2), clothing: @clothes[0])
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 2), clothing: @clothes[4])
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 3), clothing: @clothes[0])
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 3), clothing: @clothes[4])
      create(:clothing_log, user: @u, date: Date.new(2013, 1, 5), clothing: @clothes[5])
    end
    context "when given a time range" do
      subject { ClothingMatch.prepare_graph(@u, Date.new(2013, 1, 1)..Date.new(2013, 1, 4)) }
      it "contains only clothing nodes for the given time range" do
        subject[:clothing].size.should == 5
      end
      it "contains only clothing matches for the given time range" do
        subject[:matches].size.should == 3
      end
      it "includes the clothing" do
        subject[:clothing].should include(@clothes[3])
      end
    end
    context "when analyzing all time" do
      subject { ClothingMatch.prepare_graph(@u) }
      it "contains all the clothing nodes" do
        subject[:clothing].size.should == 5
      end
      it "summarizes the clothing matches" do
        subject[:matches].size.should == 3   # unidirectional: 0 <-> 1, 2 <-> 3, 0 <-> 4, 5 is by itself so no match
      end
      it "has weighted edges" do
        subject[:matches].should include({source: @clothes[0].id, target: @clothes[4].id, count_matches: 2})
      end
    end
  end

end
