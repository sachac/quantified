class ReceiptItemCategory < ActiveRecord::Base
  has_many :receipt_item_types
  belongs_to :user
end
