class ReceiptItem < ApplicationRecord
  belongs_to :user
  belongs_to :receipt_item_type, autosave: true
#  delegate :friendly_name, to: :receipt_item_type, allow_nil: true
#  delegate :category_name, to: :receipt_item_type, allow_nil: true
#  delegate :receipt_item_category_id, to: :receipt_item_type, allow_nil: true
  before_save :update_total

  # Creates a ReceiptItem.
  def set_associated(params)
    if params[:receipt_item_type_id] && self.receipt_item_type_id != params[:receipt_item_type_id] then
      self.receipt_item_type = self.user.receipt_item_types.find(params[:receipt_item_type_id])
    end
      
    if !params[:friendly_name].blank? then
      # Try to reuse this user's receipt item type
      self.receipt_item_type = self.user.receipt_item_types.where(friendly_name: params[:friendly_name], receipt_name: self.name).first
      # or create a new one if necessary
      if receipt_item_type.nil? then
        self.receipt_item_type = self.user.receipt_item_types.create(friendly_name: params[:friendly_name], receipt_name: self.name)
      end
    else
      self.receipt_item_type = self.user.receipt_item_types.where(receipt_name: self.name).first
    end
    if params[:receipt_item_category_id] and self.receipt_item_type.receipt_item_category_id != params[:receipt_item_category_id] then
      self.receipt_item_type.receipt_item_category = self.user.receipt_item_categories.find(params[:receipt_item_category_id])
    end
      
    if !params[:category_name].blank? then
      # Try to reuse this user's receipt item type
      self.receipt_item_type.receipt_item_category = user.receipt_item_categories.where(name: params[:category_name]).first
      # or create a new one if necessary
      if receipt_item_type.receipt_item_category.nil? then
        self.receipt_item_type.receipt_item_category = user.receipt_item_categories.create(name: params[:category_name])
      end
    end
  end
  
  
  def update_total
    if !self.total and self.quantity and self.unit_price
      self.total = self.quantity * self.unit_price
    end
  end
  
  def self.parse_batch(text)
    text = text.strip
    h = ['ID', 'File', 'Store', 'Date', 'Time', 'Name', 'Quantity or net weight', 'Unit', 'Unit price', 'Total', 'Notes']
    csv = CSV::parse(text, headers: h, col_sep: "\t")
    csv = CSV::parse(text, headers: true, col_sep: "\t") if csv[0]['ID'] == 'ID'
    csv
  end

  def set_from_row(row)
    self.filename = (row['File'] || '').strip
    self.store = (row['Store'] || '').strip
    self.date = Time.zone.parse(row['Date']).to_date
    self.name = (row['Name'] || '').strip
    self.quantity = row['Quantity'].blank? ? 1 : row['Quantity'].to_f
    self.source_id = (row['ID'] || '').strip
    self.source_name = 'batch'
    self.store = (row['Store'] || '').strip
    self.unit = (row['Unit'] || '').strip
    self.unit_price = row['Unit price'].blank? ? nil : row['Unit price'].to_f
    self.total = row['Total'].blank? ? nil : row['Total'].to_f
    self.notes = (row['Notes'] || '').strip
  end
  
  def self.create_batch(user, csv)
    result = {created: Array.new, updated: Array.new, failed: Array.new}
    csv.each do |row|
      status = :created
      if row['ID'].blank?
        # Create unconditionally
        rec = user.receipt_items.new
      else
        # Replace the current one if it exists or create it
        rec = user.receipt_items.where('source_id=? AND source_name=?', row['ID'].strip, 'batch').first
        if rec then
          status = :updated
        else
          rec = user.receipt_items.new
        end
      end
      rec.set_from_row(row)
      if rec.save
        result[status] << rec
      else
        result[:failed] << rec
      end
    end
    result
  end

  comma do
    filename
    source_id
    source_name
    store
    date
    name
    receipt_item_type :friendly_name => 'friendly_name'
    receipt_item_type 'category_name' do |type| type.receipt_item_category.name if type and type.receipt_item_category end
    quantity
    unit
    unit_price
    total
    notes
  end

  scope :include_names, -> { joins('LEFT JOIN receipt_item_types ON receipt_items.receipt_item_type_id=receipt_item_types.id LEFT JOIN receipt_item_categories ON receipt_item_types.receipt_item_category_id=receipt_item_categories.id').select('receipt_items.*, receipt_item_types.friendly_name, receipt_item_types.receipt_item_category_id, receipt_item_categories.name AS category_name') }
end
