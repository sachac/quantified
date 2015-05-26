class ReceiptItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :receipt_item_type
  delegate :friendly_name, to: :receipt_item_type, allow_nil: true
  before_save :update_total

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
    friendly_name
    quantity
    unit
    unit_price
    total
    notes
  end

  def as_json(options={})
    super(:include => [:receipt_item_type])
  end
end
