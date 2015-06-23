class ReceiptItemType < ActiveRecord::Base
  has_many :receipt_items, :dependent => :delete_all
  belongs_to :user
  belongs_to :receipt_item_category
  delegate :name, to: :receipt_item_category, prefix: :category, allow_nil: true
  def self.set_name_and_category(user, receipt_name, friendly_name, category_id = nil)
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
    user.receipt_items.joins('LEFT JOIN receipt_item_types ON (receipt_items.receipt_item_type_id=receipt_item_types.id)').where('receipt_item_type_id IS NULL OR receipt_item_category_id IS NULL').select('receipt_item_types.id, receipt_item_types.id AS receipt_item_type_id, name, friendly_name, count(name) AS name_count').group(:name).order('name_count DESC')
  end

end
