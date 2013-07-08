class ReceiptItemCategory < ActiveRecord::Base
  attr_accessible :name
  has_many :receipt_item_types
  belongs_to :user
end
