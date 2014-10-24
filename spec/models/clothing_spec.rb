require 'spec_helper'

describe Clothing do
  it "has a friendly name for autocomplete" do
    o = create(:clothing, :name => 'foo')
    expect(o.autocomplete_view).to eq "#{o.id} - foo"
  end
  describe '#update_hsl' do
    it "handles a color" do
      o = create(:clothing, name: 'foo', color: '112233')
      expect(o.hue).to be_within(0.01).of 0.583
      expect(o.saturation).to be_within(0.01).of 0.5
      expect(o.brightness).to be_within(0.01).of 13.3/100
    end
    it "handles black" do
      o = create(:clothing, name: 'foo', color: '000000')
      expect(o.brightness).to be_within(0.01).of 0
    end
    it "handles white" do
      o = create(:clothing, name: 'foo', color: 'ffffff')
      expect(o.brightness).to be_within(0.01).of 1
    end
  end
  describe '#get_color' do
    context "when there's an attached image" do
      it "guesses the color from a file" do
        o = create(:clothing)
        o.image = File.new('spec/fixtures/files/sample-color-ff0000.png')
        allow(o.image).to receive(:path).and_return(Rails.root.join('spec/fixtures/files/sample-color-ff0000.png'))
        color = o.get_color
        expect(color.red).to be_within(0.01).of 255
        expect(color.green).to be_within(0.01).of 25
        expect(color.blue).to be_within(0.01).of 25
      end
    end
    context "when multiple colors are specified" do
      it "uses the first one defined" do
        o = build_stubbed(:clothing, color: 'ff0000,ffffff')
        color = o.get_color
        expect(color.red).to be_within(0.01).of 255
        expect(color.green).to be_within(0.01).of 0
        expect(color.blue).to be_within(0.01).of 0
      end
    end
  end
  describe '#update_stats' do
    before(:each) do 
      @o = create(:clothing, color: 'ff0000,ffffff')
    end
    it "starts with a blank slate" do
      expect(@o.last_worn).to be_nil
      expect(@o.last_clothing_log_id).to be_nil
    end
    it "keeps track of the last worn date" do
      x = create(:clothing_log, clothing: @o, user: @o.user, date: Time.zone.today - 4.days)
      create(:clothing_log, clothing: @o, user: @o.user, date: Time.zone.today - 8.days)
      @o.reload
      expect(@o.last_worn).to eq Time.zone.today - 4.days
      expect(@o.last_clothing_log_id).to eq x.id
    end
  end
  it "can navigate to the next and previous one" do
    u = create(:confirmed_user)
    o = create(:clothing, user: u)
    create(:clothing)
    o2 = create(:clothing, user: u)
    expect(o.previous_by_id).to be_nil
    expect(o.next_by_id).to eq o2
    expect(o2.previous_by_id).to eq o
    expect(o2.next_by_id).to be_nil
  end

  describe ".guess_color" do
    context "when the position is specified" do
      it "guesses the color" do
        path = Rails.root.join('spec/fixtures/files/sample-color-ff0000.png')
        expect(Clothing.guess_color(path, '1', '1')).to eq 'ffffff'
      end
    end
    context "when the position is not specified" do
      it "averages the color" do
        path = Rails.root.join('spec/fixtures/files/sample-color-ff0000.png')
        expect(Clothing.guess_color(path)).to eq 'ff1919'
      end
    end
  end

  describe '#add_color' do
    it "replaces the color if blank" do
      c = build_stubbed(:clothing)
      c.add_color('ffffff')
      expect(c.color).to eq 'ffffff'
    end
  end
  it "can be converted to XML" do
    o = create(:clothing, name: 'T-shirt')
    expect(o.to_xml).to match 'T-shirt'
  end

  it "can be converted to CSV" do
    o = create(:clothing, name: 'T-shirt', clothing_type: 'top',
               status: 'active', color: '000000')
    expect(o.to_comma).to eq [o.id.to_s,
                          'T-shirt',
                          'top',
                          'active',
                          '000000',
                          nil,
                          '0',
                          nil,
                          nil]
  end

end
