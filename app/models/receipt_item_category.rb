class ReceiptItemCategory < ActiveRecord::Base
  has_many :receipt_item_types
  belongs_to :user
  private
  def receipt_item_category_params
    params.require(:name)
  end
end
