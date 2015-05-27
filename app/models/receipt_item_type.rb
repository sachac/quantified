class ReceiptItemType < ActiveRecord::Base
  has_many :receipt_items
  belongs_to :user
  belongs_to :receipt_item_category
  
  def self.map(user, receipt_name, friendly_name, category_id = nil)
    type = user.receipt_item_types.create(friendly_name: friendly_name,
                                          receipt_name: receipt_name,
                                          receipt_item_category_id: category_id)
                                  
    {type: type, count: type.map}
  end

  def map
    # Find unmapped items with the same name
    unmapped = user.receipt_items.where(receipt_item_type_id: nil,
                                        name: self.receipt_name)
    count = unmapped.count
    unmapped.update_all(receipt_item_type_id: self.id)
    count
  end

  def move_to(new_item_type)
    if self.receipt_items.update_all(receipt_item_type_id: new_item_type.id)
      self.delete
    end
  end
  
  def self.list_unmapped(user)
    user.receipt_items.where(receipt_item_type_id: nil).select('name, count(name) AS name_count').group(:name).order('name_count DESC')
  end

end
