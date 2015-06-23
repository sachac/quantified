require 'spec_helper'

describe ReceiptItem do
  before do
    @text = 'ID	File	Store	Date	Time	Name	Quantity or net weight	Unit	Unit price	Total	Notes
2	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	11:00	RN Dried Apricot M	1		4	4	'
  end
  describe ".create_associated" do
    it "creates the receipt item type if it does not yet exist" do
      u = create(:user)
      o = ReceiptItem.create(:user => u, :name => 'hamburgers')
      o.set_associated({friendly_name: 'Hamburgers', category_name: 'Meat'})
      o.save!
      o.receipt_item_type.should_not be_nil
      o.receipt_item_type.receipt_name.should eq 'hamburgers'
      o.receipt_item_type.friendly_name.should eq 'Hamburgers'
      o.receipt_item_type.receipt_item_category.name.should eq 'Meat'
    end
    it "guesses the receipt item type if it already exists" do
      u = create(:user)
      t = create(:receipt_item_type, user: u, receipt_name: 'hamburgers', friendly_name: 'Hamburgers')
      o = ReceiptItem.create(:user => u, name: 'hamburgers')
      o.set_associated(friendly_name: nil, category_name: nil)
      o.save!
      o.receipt_item_type.receipt_name.should eq 'hamburgers'
      o.receipt_item_type.friendly_name.should eq 'Hamburgers'
      o.receipt_item_type_id.should == t.id
    end
    it "reuses the receipt item type if it already exists" do
      u = create(:user)
      t = create(:receipt_item_type, user: u, receipt_name: 'hamburgers', friendly_name: 'Hamburgers')
      o = ReceiptItem.create(:user => u, name: 'hamburgers')
      o.set_associated(friendly_name: 'Hamburgers')
      o.save!
      o.receipt_item_type.should_not be_nil
      o.receipt_item_type.receipt_name.should eq 'hamburgers'
      o.receipt_item_type.friendly_name.should eq 'Hamburgers'
      o.receipt_item_type.id.should == t.id
    end
    it "reuses the receipt item type if it already exists, even if specified" do
      u = create(:user)
      t = create(:receipt_item_type, user: u, receipt_name: 'hamburgers', friendly_name: 'Hamburgers')
      o = ReceiptItem.create(:user => u, name: 'hamburgers')
      o.set_associated(friendly_name: 'Hamburgers')
      o.save!
      o.receipt_item_type.id.should == t.id
    end
    it "creates the receipt item category if it does not yet exist" do
      u = create(:user)
      o = ReceiptItem.create(:user => u, :name => 'hamburgers')
      o.set_associated(friendly_name: 'Hamburgers', category_name: 'Meat')
      o.save!
      o.receipt_item_type.receipt_item_category.name.should eq 'Meat'
    end
    it "reuses the receipt item category if it already exists" do
      u = create(:user)
      c = create(:receipt_item_category, user: u, name: 'Meat')
      o = ReceiptItem.create(user: u, name: 'hamburgers')
      o.set_associated(friendly_name: 'Hamburgers', category_name: 'Meat')
      o.save!
      o.receipt_item_type.receipt_item_category_id.should == c.id
    end
    it "doesn't steal other people's types" do
      u = create(:user)
      u2 = create(:user)
      t = create(:receipt_item_type, user: u2, receipt_name: 'hamburgers', friendly_name: 'Hamburgers')
      o = ReceiptItem.create(:user => u, name: 'hamburgers')
      o.set_associated(friendly_name: nil, category_name: nil)
      o.save!
      o.receipt_item_type.should be_nil
    end
  end
  describe ".parse_batch" do
    it "converts to CSV with headers" do
      text = '2	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	11:00	RN Dried Apricot M	1		4	4	'
      r = ReceiptItem.parse_batch(text)
      expect(r[0]['ID']).to eq '2'
      expect(r[0]['File']).to eq '2131936.jpg'
      expect(r[0]['Store']).to eq 'Nofrills Lower Food Prices'
      expect(r[0]['Date']).to eq '2012-02-23'
      expect(r[0]['Name']).to eq 'RN Dried Apricot M'
      expect(r[0]['Quantity or net weight']).to eq '1'
      expect(r[0]['Unit price']).to eq '4'
      expect(r[0]['Total']).to eq '4'
    end
    it "converts to CSV even without headers" do
      r = ReceiptItem.parse_batch(@text)
      expect(r[0]['ID']).to eq '2'
      expect(r[0]['File']).to eq '2131936.jpg'
    end
  end
  describe '#set_from_row' do
    it "sets the attributes" do
      data = ReceiptItem.parse_batch(@text)
      r = ReceiptItem.new
      r.set_from_row(data[0])
      expect(r.unit_price).to be_within(0.01).of(4)
      expect(r.name).to eq 'RN Dried Apricot M'
    end
  end
  describe '.create_batch' do
    before do
      @data = ReceiptItem.parse_batch(@text)
      @user = create(:user, :confirmed)
    end
    it "should create" do
      result = ReceiptItem.create_batch(@user, @data)
      expect(result[:created].size).to eq 1
      expect(ReceiptItem.last.name).to eq 'RN Dried Apricot M'
      expect(ReceiptItem.last.user).to eq @user
    end
    it "should update" do
      x = create(:receipt_item, user: @user, source_name: 'batch', source_id: '2')
      result = ReceiptItem.create_batch(@user, @data)
      expect(result[:updated].size).to eq 1
      expect(x.reload.name).to eq 'RN Dried Apricot M'
    end
    it "should report failure if necessary" do
      expect_any_instance_of(ReceiptItem).to receive(:save).and_return(false)
      result = ReceiptItem.create_batch(@user, @data)
      expect(result[:failed].size).to eq 1
    end
    it "creates unconditionally if ID is blank" do
      text = "1	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	11:00	RN Dried Apricot M	1		4	4	\n"
      text += "	2131936.jpg	Nofrills Lower Food Prices	2012-02-23	11:00	RN Dried Apricot M	1		4	4	\n"
      r = ReceiptItem.parse_batch(text)
      ReceiptItem.create_batch(@user, r)
      expect(ReceiptItem.count).to eq 2
    end
  end
  describe "#to_csv" do
    it "should convert to CSV" do
      rec = FactoryGirl.create(:receipt_item)
      expect(rec.to_comma).to eq [rec.filename, rec.source_id.to_s, rec.source_name, rec.store, rec.date.to_s, rec.name, nil, nil, rec.quantity.to_s, rec.unit, rec.unit_price.to_s, rec.total.to_s, rec.notes]
    end
  end

end
