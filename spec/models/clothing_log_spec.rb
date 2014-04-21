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
    log = FactoryGirl.build_stubbed(:clothing_log)
    log.to_xml.should match 'clothing-name'
    log.to_xml.should match log.clothing.name
  end
  it "converts to JSON" do
    log = FactoryGirl.build_stubbed(:clothing_log)
    log.to_json.should match 'clothing_name'
    log.to_json.should match log.clothing.name
  end
  it "converts to CSV" do
    log = FactoryGirl.build_stubbed(:clothing_log, date: Date.new(2014, 4, 1))
    log.to_comma.should == [log.clothing_id.to_s,
                            log.date.to_s,
                            "1",
                            log.clothing.name,
                            '2014-04-04',
                            '2014-04-30',
                            '2014-12-31']
  end
  describe "#summarize" do
    before do 
      time = Time.zone.local(2014, 4, 30, 8)
      Timecop.freeze(@time)
      @user = FactoryGirl.build_stubbed(:user)
      @c1 = FactoryGirl.build_stubbed(:clothing, user: @user)
      @c2 = FactoryGirl.build_stubbed(:clothing, user: @user)
      @logs = Array.new
      # By default, week
      @logs << FactoryGirl.build_stubbed(:clothing_log, clothing: @c1, user: @user, date: Time.zone.local(2014, 4, 8, 8))
      @logs << FactoryGirl.build_stubbed(:clothing_log, clothing: @c1, user: @user, date: Time.zone.local(2014, 4, 9, 8))
      @logs << FactoryGirl.build_stubbed(:clothing_log, clothing: @c1, user: @user, date: Time.zone.local(2014, 4, 16, 8))
      @logs << FactoryGirl.build_stubbed(:clothing_log, clothing: @c2, user: @user, date: Time.zone.local(2014, 4, 9, 8))
      @logs << FactoryGirl.build_stubbed(:clothing_log, clothing: @c1, user: @user, date: Time.zone.local(2014, 3, 2, 8))

    end
    after do
      Timecop.return
    end
    it "summarizes by day" do
      result = ClothingLog.summarize(zoom: 'daily', records: @logs, user: @user)
      result[@c1.id][:sums][Date.new(2014, 4, 8)].should == 1
      result[@c1.id][:sums][Date.new(2014, 4, 6)].should be_nil
    end
    it "summarizes by week" do
      result = ClothingLog.summarize(zoom: 'weekly', records: @logs, user: @user)
      result[@c1.id][:sums][Date.new(2014, 4, 11)].should == 2
      result[@c1.id][:sums][Date.new(2014, 4, 18)].should == 1
      result[@c2.id][:sums][Date.new(2014, 4, 11)].should == 1
    end
    it "summarizes by month" do
      result = ClothingLog.summarize(zoom: 'monthly', records: @logs, user: @user)
      result[@c1.id][:sums][Date.new(2014, 4, 30)].should == 3
    end
    it "summarizes by year" do
      result = ClothingLog.summarize(zoom: 'yearly', records: @logs, user: @user)
      result[@c1.id][:sums][Date.new(2014, 12, 31)].should == 4
      result[@c1.id][:total].should == 4
    end
  end

end
