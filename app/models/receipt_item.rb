class ReceiptItem < ActiveRecord::Base
  attr_accessible :date, :filename, :name, :notes, :quantity, :source_id, :source_name, :store, :total, :unit, :unit_price
  belongs_to :user
  belongs_to :receipt_item_type
  delegate :friendly_name, to: :receipt_item_type, allow_nil: true


  def self.parse_batch(text)
    text = text.strip
    h = ['ID', 'File', 'Store', 'Date', 'Time', 'Name', 'Quantity or net weight', 'Unit', 'Unit price', 'Total', 'Notes']
    csv = CSV::parse(text, headers: h, col_sep: "\t")
    csv = CSV::parse(text, headers: true, col_sep: "\t") if csv[0]['ID'] == 'ID'
    csv
  end

  def set_from_row(row)
    update_attributes(filename: (row['File'] || '').strip,
                      store: (row['Store'] || '').strip,
                      date: Time.zone.parse(row['Date']).to_date,
                      name: (row['Name'] || '').strip,
                      quantity: row['Quantity'].blank? ? 1 : row['Quantity'].to_f,
                      source_id: (row['ID'] || '').strip,
                      source_name: 'batch',
                      store: (row['Store'] || '').strip,
                      unit: (row['Unit'] || '').strip,
                      unit_price: row['Unit price'].blank? ? nil : row['Unit price'].to_f,
                      total: row['Total'].blank? ? nil : row['Total'].to_f,
                      notes: (row['Notes'] || '').strip)
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
end
