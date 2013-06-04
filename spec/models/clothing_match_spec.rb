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

end
