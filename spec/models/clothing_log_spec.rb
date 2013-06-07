require 'spec_helper'
describe ClothingLog do
  describe '#update_matches' do
    it "keeps track of clothing" do
      @user = FactoryGirl.create(:user)
      c1 = FactoryGirl.create(:clothing, user: @user)
      c2 = FactoryGirl.create(:clothing, user: @user)
      c3 = FactoryGirl.create(:clothing, user: @user)
      FactoryGirl.create(:clothing_log, clothing: c1, user: @user, date: Time.zone.today)
      FactoryGirl.create(:clothing_log, clothing: c2, user: @user, date: Time.zone.today)  
      c1.reload
      c1.clothing_matches.size.should == 1
    end
    context "when the clothing ID changes" do
      it "updates the matches" do
        @user = FactoryGirl.create(:user)
        c1 = FactoryGirl.create(:clothing, user: @user)
        c2 = FactoryGirl.create(:clothing, user: @user)
        c3 = FactoryGirl.create(:clothing, user: @user)
        log = FactoryGirl.create(:clothing_log, clothing: c1, user: @user, date: Time.zone.today)
        FactoryGirl.create(:clothing_log, clothing: c2, user: @user, date: Time.zone.today)  
        log.clothing = c2
        log.save
        c1.reload
        c1.clothing_matches.size.should == 0
      end
    end
  end
  it "clears things after clothing is deleted" do
    @user = FactoryGirl.create(:user)
    c1 = FactoryGirl.create(:clothing, user: @user)
    c2 = FactoryGirl.create(:clothing, user: @user)
    c3 = FactoryGirl.create(:clothing, user: @user)
    log = FactoryGirl.create(:clothing_log, clothing: c1, user: @user, date: Time.zone.today)
    FactoryGirl.create(:clothing_log, clothing: c2, user: @user, date: Time.zone.today)
    c2.clothing_matches.size.should == 1
    c1.destroy
    c2.clothing_matches.size.should == 0
  end
  it "indexes logs by date" do
    @user = FactoryGirl.create(:user)
    c1 = FactoryGirl.create(:clothing, user: @user)
    c2 = FactoryGirl.create(:clothing, user: @user)
    c3 = FactoryGirl.create(:clothing, user: @user)
    log1 = FactoryGirl.create(:clothing_log, clothing: c1, user: @user, date: Time.zone.today - 1.day)
    log2 = FactoryGirl.create(:clothing_log, clothing: c2, user: @user, date: Time.zone.today - 1.day)
    log3 = FactoryGirl.create(:clothing_log, clothing: c3, user: @user, date: Time.zone.today)
    result = ClothingLog.by_date(@user.clothing_logs)
    result[Time.zone.today].should == [log3]
    result[Time.zone.today - 1.day].should == [log1, log2]
  end
  it "converts to XML" do
    log = FactoryGirl.create(:clothing_log)
    log.to_xml.should match 'clothing-name'
    log.to_xml.should match log.clothing.name
  end
  it "converts to JSON" do
    log = FactoryGirl.create(:clothing_log)
    log.to_json.should match 'clothing_name'
    log.to_json.should match log.clothing.name
  end
  it "converts to CSV" do
    log = FactoryGirl.create(:clothing_log)
    log.to_comma.should == [log.clothing_id.to_s,
                            log.date.to_s,
                            "1",
                            log.clothing.name]
  end
end
