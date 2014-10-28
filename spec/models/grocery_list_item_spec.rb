require 'spec_helper'

RSpec.describe GroceryListItem, :type => :model do
  before(:each) do
    @user = create(:user, :confirmed)
    @grocery_list = create(:grocery_list, user: @user)
    create(:receipt_item_type, friendly_name: 'Apples', receipt_item_category: create(:receipt_item_category, name: 'Produce', user: @user), user: @user)
    create(:receipt_item_type, friendly_name: 'Chicken', receipt_item_category: create(:receipt_item_category, name: 'Meat', user: @user), user: @user)
  end
  describe '#guess_category' do
    it 'fills in the category if one has not been specified, but the friendly name matches' do
      item = @grocery_list.grocery_list_items.new(name: 'Apples')
      item.guess_category
      expect(item.receipt_item_category.name).to eq 'Produce'
      expect(item.category).to eq 'Produce'
    end
  end
  describe '#category=' do
    it 'creates a category if necessary' do
      item = GroceryListItem.new(name: 'Bananas', grocery_list_id: @grocery_list.id, category: 'Produce')
      expect(item.receipt_item_category.name).to eq 'Produce'
      expect(item.receipt_item_category).to_not be_nil
    end
    it 'reuses a category if it exists' do
      item = @grocery_list.grocery_list_items.new(name: 'Cheese', grocery_list: @grocery_list, category: 'Deli')
      expect(item.receipt_item_category.name).to eq 'Deli'
    end
  end
end
