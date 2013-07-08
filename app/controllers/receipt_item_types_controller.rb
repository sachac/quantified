class ReceiptItemTypesController < ApplicationController
  before_filter :authenticate_managing!
  respond_to :html, :xml, :json, :csv
  # GET /receipt_item_types
  # GET /receipt_item_types.json
  def index
    @receipt_item_types = current_account.receipt_item_types.all
    respond_with @receipt_item_types
  end

  # GET /receipt_item_types/1
  # GET /receipt_item_types/1.json
  def show
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    @same_name = current_account.receipt_item_types.where(friendly_name: @receipt_item_type.friendly_name)
    params[:start] ||= (Time.zone.now - 1.month).to_date.to_s
    params[:end] ||= (Time.zone.now + 1.day).to_date.to_s
    prepare_filters :date_range
    @start = Time.zone.parse(params[:start])
    @end = Time.zone.parse(params[:end])
    @items = @same_name.joins('LEFT JOIN receipt_items ON (receipt_item_types.id=receipt_items.receipt_item_type_id)')
    @items = @items.where('date >= ? AND date < ?', @start, @end)
    list = { item: @receipt_item_type, same_name: @same_name }
    respond_with list
  end

  # GET /receipt_item_types/new
  # GET /receipt_item_types/new.json
  def new
    @receipt_item_type = current_account.receipt_item_types.new
    respond_with @receipt_item_type
  end

  # GET /receipt_item_types/1/edit
  def edit
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
  end

  # POST /receipt_item_types
  # POST /receipt_item_types.json
  def create
    params[:receipt_item_type].delete(:user_id) if params[:receipt_item_type]
    @receipt_item_type = current_account.receipt_item_types.new(params[:receipt_item_type])
    if @receipt_item_type.save
      @receipt_item_type.map
      add_flash :notice, t('receipt_item_type.created')
    end
    respond_with @receipt_item_type
  end

  # PUT /receipt_item_types/1
  # PUT /receipt_item_types/1.json
  def update
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    params[:receipt_item_type].delete(:user_id) if params[:receipt_item_type]
    if @receipt_item_type.update_attributes(params[:receipt_item_type])
      add_flash :notice, t('receipt_item_type.updated')
    end
    respond_with @receipt_item_type
  end

  # DELETE /receipt_item_types/1
  # DELETE /receipt_item_types/1.json
  def destroy
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    @receipt_item_type.destroy
    respond_with @receipt_item_type, location: receipt_item_types_url 
  end

  def batch_entry
    @unmapped = ReceiptItemType.list_unmapped(current_account)
    count = 0
    @result = Hash.new
    @receipt_item_categories = current_account.receipt_item_categories.order(:name)
    if params[:batch]
      params[:batch].each do |k, x|
        if !x[:friendly_name].blank?
          result = ReceiptItemType.map(current_account, x[:receipt_name], x[:friendly_name], x[:receipt_item_category_id])
          count += result[:count]
          @result[x[:receipt_name]] = result
        end
      end
      if count > 0
        add_flash :notice, "#{count} receipt item(s) updated."
      end
    end
    respond_with @result
  end
end
