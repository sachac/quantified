class ReceiptItemTypesController < ApplicationController
  before_action :authenticate_managing!
  respond_to :html, :xml, :json, :csv
  # GET /receipt_item_types
  # GET /receipt_item_types.json
  def index
    order = filter_sortable_column_order %w{friendly_name receipt_name receipt_item_category.name}
    @receipt_item_types = current_account.receipt_item_types.include_names.order(order)
    respond_with @receipt_item_types
  end

  # GET /receipt_item_types/1
  # GET /receipt_item_types/1.json
  def show
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    @same_name = current_account.receipt_item_types.where(friendly_name: @receipt_item_type.friendly_name)
    params[:start] = current_account.receipt_items.minimum(:date).to_s if params[:start].blank?
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
    @receipt_item_type = current_account.receipt_item_types.create(receipt_item_type_params)
    if @receipt_item_type
      respond_with @receipt_item_type do |format|
        format.json { render :json => current_account.receipt_item_types.include_names.find(@receipt_item_type.id) }
      end
    else
      respond_with @receipt_item_type
    end
  end

  # PUT /receipt_item_types/1
  # PUT /receipt_item_types/1.json
  def update
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    params[:receipt_item_type].delete(:user_id) if params[:receipt_item_type]
    @receipt_item_category = current_account.receipt_item_categories.find(params[:receipt_item_type][:receipt_item_category_id]) if params[:receipt_item_type][:receipt_item_category_id]
    if @receipt_item_category
      @receipt_item_type.receipt_item_category_id = @receipt_item_category.id
      params[:receipt_item_type].delete(:receipt_item_type_id)
    end
    if @receipt_item_type.update_attributes(receipt_item_type_params)
      add_flash :notice, t('receipt_item_type.updated')
      respond_with @receipt_item_type do |format|
        format.json { render :json => current_account.receipt_item_types.include_names.find(@receipt_item_type.id) }
      end
    else
      respond_with @receipt_item_type
    end
  end

  # DELETE /receipt_item_types/1
  # DELETE /receipt_item_types/1.json
  def destroy
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    @receipt_item_type.destroy
    respond_with @receipt_item_type, location: receipt_item_types_url 
  end

  def latest_receipt_items
    @receipt_item_type = current_account.receipt_item_types.find(params[:id])
    respond_with @receipt_item_type.receipt_items.order(:date => :desc).limit((params[:limit] || 10).to_i)
    
  end
  
  def batch_entry
    @unmapped = ReceiptItemType.list_unmapped(current_account)
    count = 0
    @result = Hash.new
    @receipt_item_categories = current_account.receipt_item_categories.order(:name)
    if params[:batch]
      params[:batch].each do |k, x|
        if !x[:friendly_name].blank?
          result = ReceiptItemType.set_name_and_category(current_account,
                                                         {receipt_name: x[:receipt_name],
                                                          friendly_name: x[:friendly_name],
                                                          category_id: x[:receipt_item_category_id]})
          count += result[:count]
          @result[x[:receipt_name]] = result
        end
      end
      if count > 0
        add_flash :notice, "#{count} receipt item(s) updated."
      end
      respond_with @result
    else
      respond_with @unmapped
    end
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:user_id => current_account.id)
  end

  def move_to
    old_type = current_account.receipt_item_types.find(params[:id])
    new_type = current_account.receipt_item_types.find(params[:new_id])
    if old_type && new_type && old_type.id != new_type.id
      old_type.move_to(new_type)
      respond_with(new_type)
    else
      respond_with('Could not find item types in your account.', status: 404)
    end
  end

  private
  def receipt_item_type_params
    params.require(:receipt_item_type).permit(:friendly_name, :receipt_name)
  end
end
