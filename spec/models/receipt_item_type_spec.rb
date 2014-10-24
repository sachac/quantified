require 'spec_helper'

describe ReceiptItemType do
  before do
    @user = create(:user, :confirmed)
  end
  describe '#map_item_name_to_type' do
    it "sets unmapped items" do
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      x = ReceiptItemType.map(@user, 'RCPT ITEM', 'Receipt item')
      expect(item.reload.receipt_item_type_id).to eq x[:type].id
      expect(item.reload.friendly_name).to eq 'Receipt item'
      expect(x[:count]).to eq 1
    end
    it "does not override mapped items" do
      old_type = create(:receipt_item_type, user: @user)
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM', receipt_item_type: old_type)
      item2 = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      x = ReceiptItemType.map(@user, 'RCPT ITEM', 'Receipt item')
      expect(item.reload.receipt_item_type_id).to eq old_type.id
      expect(item2.reload.receipt_item_type_id).to eq x[:type].id
      expect(x[:count]).to eq 1
    end
  end
  describe '#list_unmapped' do
    it "returns unmapped strings" do
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      item2 = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      item3 = create(:receipt_item, user: @user, name: 'RCPT ITEM BLAH', receipt_item_type: create(:receipt_item_type, user: @user))
      expect(ReceiptItemType.list_unmapped(@user).map(&:name)).to eq ['RCPT ITEM']
    end
  end
end
