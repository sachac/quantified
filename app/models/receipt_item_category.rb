class ReceiptItemCategory < ApplicationRecord
  has_many :receipt_item_types
  belongs_to :user
end
