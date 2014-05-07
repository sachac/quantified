class ReceiptItemsController < ApplicationController
  respond_to :html, :xml, :json, :csv
  before_filter :authenticate_managing!
  
  # GET /receipt_items
  # GET /receipt_items.json
  def index
    @receipt_items = current_account.receipt_items.order('date DESC').joins('LEFT JOIN receipt_item_types ON receipt_items.receipt_item_type_id=receipt_item_types.id').select('receipt_items.*, receipt_item_types.friendly_name')
    params[:start] = (current_account.receipt_items.minimum(:date) - 1.day).to_s if params[:start].blank? and current_account.receipt_items.size > 0 
    params[:end] ||= (Time.zone.now + 1.day).midnight.to_s
    prepare_filters [:filter_string, :date_range]
    @receipt_items = @receipt_items.where(date: Time.zone.parse(params[:start])..Time.zone.parse(params[:end]))
    if !params[:filter_string].blank?
      filter = '%' + params[:filter_string].downcase + '%'
      @receipt_items = @receipt_items.where('LOWER(name) LIKE ? OR LOWER(friendly_name) LIKE ?', filter, filter)
    end
    @receipt_items = @receipt_items.paginate(page: params[:page]) unless request.format.csv?
    respond_with_data @receipt_items
  end

  # GET /receipt_items/1
  # GET /receipt_items/1.json
  def show
    @receipt_item = current_account.receipt_items.find(params[:id])
    respond_with @receipt_item
  end

  # GET /receipt_items/new
  # GET /receipt_items/new.json
  def new
    @receipt_item = current_account.receipt_items.new
    respond_with @receipt_item
  end

  # GET /receipt_items/1/edit
  def edit
    @receipt_item = current_account.receipt_items.find(params[:id])
    respond_with @receipt_item
  end

  # POST /receipt_items
  # POST /receipt_items.json
  def create
    if params[:receipt_item] then params[:receipt_item].delete(:user_id) end
    @receipt_item = current_account.receipt_items.new(params[:receipt_item])
    if @receipt_item.save
      add_flash :notice, I18n.t('receipt_item.created')
    end
    respond_with @receipt_item
  end

  # PUT /receipt_items/1
  # PUT /receipt_items/1.json
  def update
    @receipt_item = current_account.receipt_items.find(params[:id])
    if params[:receipt_item] then params[:receipt_item].delete(:user_id) end
    if @receipt_item.update_attributes(params[:receipt_item])
      add_flash :notice, I18n.t('receipt_item.updated')
    end
    respond_with @receipt_item
  end

  # DELETE /receipt_items/1
  # DELETE /receipt_items/1.json
  def destroy
    @receipt_item = current_account.receipt_items.find(params[:id])
    @receipt_item.destroy
    respond_with @receipt_item, location: receipt_items_url
  end

  def batch_entry
    if params[:batch]
      @result = ReceiptItem.parse_batch(params[:batch])
    end
    if params[:confirm_data]
      @outcome = ReceiptItem.create_batch(current_account, @result)
      loc = receipt_items_path
      if @outcome[:created].size > 0
        add_flash :notice, "#{@outcome[:created].size} record(s) created."
      end
      if @outcome[:updated].size > 0
        add_flash :notice, "#{@outcome[:updated].size} record(s) updated."
      end
      if @outcome[:failed].size > 0
        add_flash :notice, "#{@outcome[:failed].size} record(s) failed."
        loc = nil
      end
      respond_with(@outcome, location: loc)
    else
      respond_with @result
    end
  end

  def graph
    params[:start] ||= (current_account.receipt_items.minimum(:date) - 1.day).to_s if params[:start].blank? and current_account.receipt_items.size > 0
    prepare_filters :date_range
    base = current_account.receipt_item_types.joins('INNER JOIN receipt_items ON receipt_item_types.id=receipt_items.receipt_item_type_id INNER JOIN receipt_item_categories ON receipt_item_types.receipt_item_category_id=receipt_item_categories.id').select('receipt_item_types.friendly_name, receipt_item_categories.name, SUM(total) AS total').where('NOT(receipt_item_categories.name IN (?))', ['Non-grocery', 'Gifts', 'Gardening supplies', 'Pet care']).where('date >= ? AND date < ?', Time.zone.parse(params[:start]).to_date, Time.zone.parse(params[:end]).to_date)
    @receipt_item_types = base.group('receipt_item_types.friendly_name').order("total DESC")
    @total = base.sum('total')
    list = Hash.new
    @receipt_item_types.each do |x|
      if !list[x[:name]]
        list[x[:name]] = {name: x[:name], children: Array.new, total: 0}
      end
      list[x[:name]][:children] << {name: x[:friendly_name], total: x[:total], size: x[:total].to_f,
        label: "#{x[:friendly_name]} - #{'%.2f' % (x[:total] || 0)} (#{((@total > 0) ? ("%d%%" % (x[:total] * 100.0 / @total)) : "-")})"
      }
      list[x[:name]][:total] += x[:total] || 0
    end
    list.each do |k, v|
      list[k][:label] = "#{v[:name]} - #{'%.2f' % (v[:total] || 0)} (#{((@total > 0) ? ("%d%%" % (v[:total] * 100.0 / @total)) : "-")})"
    end
    @data = { name: 'Receipts', children: list.values.sort_by { |v| -(v[:total] || 0) } }
  end
end
