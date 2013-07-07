require 'spec_helper'

describe ReceiptItem do
  before do
    @text = 'ID	File	Store	Date	Name	Quantity or net weight	Unit	Unit price	Total	Notes
2	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	RN Dried Apricot M	1		4	4	'
  end
  describe ".parse_batch" do
    it "converts to CSV with headers" do
      text = '2	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	RN Dried Apricot M	1		4	4	'
      r = ReceiptItem.parse_batch(text)
      r[0]['ID'].should == '2'
      r[0]['File'].should == '2131936.jpg'
      r[0]['Store'].should == 'Nofrills Lower Food Prices'
      r[0]['Date'].should == '2012-02-23'
      r[0]['Name'].should == 'RN Dried Apricot M'
      r[0]['Quantity or net weight'].should == '1'
      r[0]['Unit price'].should == '4'
      r[0]['Total'].should == '4'
    end
    it "converts to CSV even without headers" do
      r = ReceiptItem.parse_batch(@text)
      r[0]['ID'].should == '2'
      r[0]['File'].should == '2131936.jpg'
    end
  end
  describe '#set_from_row' do
    it "sets the attributes" do
      data = ReceiptItem.parse_batch(@text)
      r = ReceiptItem.new
      r.set_from_row(data[0])
      r.unit_price.should be_within(0.01).of(4)
      r.name.should == 'RN Dried Apricot M'
    end
  end
  describe '.create_batch' do
    before do
      @data = ReceiptItem.parse_batch(@text)
      @user = create(:user, :confirmed)
    end
    it "should create" do
      result = ReceiptItem.create_batch(@user, @data)
      result[:created].size.should == 1
      ReceiptItem.last.name.should == 'RN Dried Apricot M'
      ReceiptItem.last.user.should == @user
    end
    it "should update" do
      x = create(:receipt_item, user: @user, source_name: 'batch', source_id: '2')
      result = ReceiptItem.create_batch(@user, @data)
      result[:updated].size.should == 1
      x.reload.name.should == 'RN Dried Apricot M'
    end
    it "should report failure if necessary" do
      ReceiptItem.any_instance.stub(:save).and_return(false)
      result = ReceiptItem.create_batch(@user, @data)
      result[:failed].size.should == 1
    end
  end
end
