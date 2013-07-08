require 'spec_helper'

describe ReceiptItemType do
  before do
    @user = create(:user, :confirmed)
  end
  describe '#map_item_name_to_type' do
    it "sets unmapped items" do
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      x = ReceiptItemType.map(@user, 'RCPT ITEM', 'Receipt item')
      item.reload.receipt_item_type_id.should == x[:type].id
      item.reload.friendly_name.should == 'Receipt item'
      x[:count].should == 1
    end
    it "does not override mapped items" do
      old_type = create(:receipt_item_type, user: @user)
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM', receipt_item_type: old_type)
      item2 = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      x = ReceiptItemType.map(@user, 'RCPT ITEM', 'Receipt item')
      item.reload.receipt_item_type_id.should == old_type.id
      item2.reload.receipt_item_type_id.should == x[:type].id
      x[:count].should == 1
    end
  end
  describe '#list_unmapped' do
    it "returns unmapped strings" do
      item = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      item2 = create(:receipt_item, user: @user, name: 'RCPT ITEM')
      item3 = create(:receipt_item, user: @user, name: 'RCPT ITEM BLAH', receipt_item_type: create(:receipt_item_type, user: @user))
      ReceiptItemType.list_unmapped(@user).map(&:name).should == ['RCPT ITEM']
    end
  end
end
