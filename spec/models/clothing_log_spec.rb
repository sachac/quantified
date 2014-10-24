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
      expect(c1.clothing_matches.size).to eq(1)
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
        expect(c1.clothing_matches.size).to eq(0)
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
    expect(c2.clothing_matches.size).to eq(1)
    c1.destroy
    expect(c2.clothing_matches.size).to eq(0)
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
    expect(result[Time.zone.today]).to eq([log3])
    expect(result[Time.zone.today - 1.day]).to eq([log1, log2])
  end
  it "converts to XML" do
    log = FactoryGirl.build_stubbed(:clothing_log)
    expect(log.to_xml).to match 'clothing-name'
    expect(log.to_xml).to match log.clothing.name
  end
  it "converts to JSON" do
    log = FactoryGirl.build_stubbed(:clothing_log)
    expect(log.to_json).to match 'clothing_name'
    expect(log.to_json).to match log.clothing.name
  end
  it "converts to CSV" do
    log = FactoryGirl.build_stubbed(:clothing_log, date: Date.new(2014, 4, 1))
    expect(log.to_comma).to eq([log.clothing_id.to_s,
                            log.date.to_s,
                            "1",
                            log.clothing.name,
                            '2014-04-04',
                            '2014-04-30',
                            '2014-12-31'])
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
      expect(result[@c1.id][:sums][Date.new(2014, 4, 8)]).to eq(1)
      expect(result[@c1.id][:sums][Date.new(2014, 4, 6)]).to be_nil
    end
    it "summarizes by week" do
      result = ClothingLog.summarize(zoom: 'weekly', records: @logs, user: @user)
      expect(result[@c1.id][:sums][Date.new(2014, 4, 11)]).to eq(2)
      expect(result[@c1.id][:sums][Date.new(2014, 4, 18)]).to eq(1)
      expect(result[@c2.id][:sums][Date.new(2014, 4, 11)]).to eq(1)
    end
    it "summarizes by month" do
      result = ClothingLog.summarize(zoom: 'monthly', records: @logs, user: @user)
      expect(result[@c1.id][:sums][Date.new(2014, 4, 30)]).to eq(3)
    end
    it "summarizes by year" do
      result = ClothingLog.summarize(zoom: 'yearly', records: @logs, user: @user)
      expect(result[@c1.id][:sums][Date.new(2014, 12, 31)]).to eq(4)
      expect(result[@c1.id][:total]).to eq(4)
    end
  end

end
