require 'spec_helper'

describe ReceiptItemType do
  before do
    @user = create(:user, :confirmed)
  end
  describe '#set_name_and_category' do
    it "sets unmapped items" do
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      x = ReceiptItemType.set_name_and_category(@user, {receipt_name: 'RCPT ITEM', friendly_name: 'Receipt item'})
      expect(item.reload.receipt_item_type_id).to eq x[:type].id
      expect(item.reload.friendly_name).to eq 'Receipt item'
      expect(x[:count]).to eq 1
    end
    it "does not override mapped items" do
      old_type = create(:receipt_item_type, user: @user)
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM', receipt_item_type: old_type)
      item2 = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      x = ReceiptItemType.set_name_and_category(@user, {receipt_name: 'RCPT ITEM', friendly_name: 'Receipt item'})
      expect(item.reload.receipt_item_type_id).to eq old_type.id
      expect(item2.reload.receipt_item_type_id).to eq x[:type].id
      expect(x[:count]).to eq 1
    end
  end
  describe '#move_to' do
    before :each do
      @type1 = create(:receipt_item_type, user: @user)
      @type2 = create(:receipt_item_type, user: @user)
      @type3 = create(:receipt_item_type, user: @user)
      @rec1 = create(:receipt_item, receipt_item_type: @type1, user: @user)
      @rec2 = create(:receipt_item, receipt_item_type: @type2, user: @user)
      @rec3 = create(:receipt_item, receipt_item_type: @type3, user: @user)
    end
    it 'moves records, but not unrelated ones' do
      @type1.move_to(@type2)
      @rec1.reload
      @rec1.receipt_item_type.id.should == @type2.id
      @rec3.reload
      @rec3.receipt_item_type.id.should == @type3.id
      @user.receipt_item_types.where(id: @type1.id).size.should == 0
    end
  end
  describe '#list_unmapped' do
    it "returns unmapped strings" do
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      item2 = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      item3 = create(:receipt_item, user: @user, name: 'RCPT ITEM BLAH', receipt_item_type: create(:receipt_item_type, user: @user, receipt_item_category: create(:receipt_item_category, user: @user)))
      expect(ReceiptItemType.list_unmapped(@user).map(&:name)).to eq ['RCPT ITEM']
    end
  end
end
