require 'spec_helper'

describe Clothing do
  it "has a friendly name for autocomplete" do
    o = FactoryGirl.create(:clothing, :name => 'foo')
    o.autocomplete_view.should == "#{o.id} - foo"
  end
  describe '#update_hsl' do
    it "handles a color" do
      o = FactoryGirl.create(:clothing, :name => 'foo', :color => '112233')
      o.hue.should be_within(0.01).of 0.583
      o.saturation.should be_within(0.01).of 0.5
      o.brightness.should be_within(0.01).of 13.3/100
    end
    it "handles black" do
      o = FactoryGirl.create(:clothing, :name => 'foo', :color => '000000')
      o.brightness.should be_within(0.01).of 0
    end
    it "handles white" do
      o = FactoryGirl.create(:clothing, :name => 'foo', :color => 'ffffff')
      o.brightness.should be_within(0.01).of 1
    end
  end
  describe '#get_color' do
    context "when there's an attached image" do
      it "guesses the color from a file" do
        o = FactoryGirl.create(:clothing)
        o.image = File.new('spec/fixtures/files/sample-color-ff0000.png')
        o.image.stub(:path).and_return(Rails.root.join('spec/fixtures/files/sample-color-ff0000.png'))
        color = o.get_color
        color.red.should be_within(0.01).of 255
        color.green.should be_within(0.01).of 25
        color.blue.should be_within(0.01).of 25
      end
    end
    context "when the file does not exist" do
      it "handles it gracefully" do
        o = FactoryGirl.create(:clothing)
        o.image = File.new('spec/fixtures/files/sample-color-ff0000.png')
        o.get_color.should be_nil
      end
    end
    context "when multiple colors are specified" do
      it "uses the first one defined" do
        o = FactoryGirl.create(:clothing, color: 'ff0000,ffffff')
        color = o.get_color
        color.red.should be_within(0.01).of 255
        color.green.should be_within(0.01).of 0
        color.blue.should be_within(0.01).of 0
      end
    end
  end
  describe '#update_stats' do
    before(:each) do 
      @o = FactoryGirl.create(:clothing, color: 'ff0000,ffffff')
    end
    it "starts with a blank slate" do
      @o.last_worn.should be_nil
      @o.last_clothing_log_id.should be_nil
    end
    it "keeps track of the last worn date" do
      x = FactoryGirl.create(:clothing_log, clothing: @o, user: @o.user, date: Time.zone.today - 4.days)
      FactoryGirl.create(:clothing_log, clothing: @o, user: @o.user, date: Time.zone.today - 8.days)
      @o.reload
      @o.last_worn.should == Time.zone.today - 4.days
      @o.last_clothing_log_id.should == x.id
    end
  end
  it "can navigate to the next and previous one" do
    u = FactoryGirl.create(:confirmed_user)
    o = FactoryGirl.create(:clothing, user: u)
    FactoryGirl.create(:clothing)
    o2 = FactoryGirl.create(:clothing, user: u)
    o.previous_by_id.should be_nil
    o.next_by_id.should == o2
    o2.previous_by_id.should == o
    o2.next_by_id.should be_nil
  end

  describe ".guess_color" do
    context "when the position is specified" do
      path = Rails.root.join('spec/fixtures/files/sample-color-ff0000.png')
      Clothing.guess_color(path, '1', '1').should == 'ffffff'
    end
    context "when the position is not specified" do
      path = Rails.root.join('spec/fixtures/files/sample-color-ff0000.png')
      Clothing.guess_color(path).should == 'ff1919'
    end
  end

  it "can be converted to XML" do
    o = FactoryGirl.create(:clothing, name: 'T-shirt')
    o.to_xml.should match 'T-shirt'
  end

  it "can be converted to CSV" do
    o = FactoryGirl.create(:clothing, name: 'T-shirt', clothing_type: 'top',
                           status: 'active', color: '000000')
    o.to_comma.should == [o.id.to_s,
                          'T-shirt',
                          'top',
                          'active',
                          '000000',
                          '',
                          '0',
                          '',
                          '']
  end

end
