class ReceiptItemCategoriesController < ApplicationController
  before_filter :authenticate_managing!
  respond_to :html, :csv, :json, :xml
  handles_sortable_columns
  # GET /receipt_item_categories
  # GET /receipt_item_categories.json
  def index
    order = sortable_column_order do |column, direction|
      case column
      when 'name'
        "#{column} #{direction}"
      when 'total'
        "#{column} #{direction}"
      else
        'total DESC'
      end
    end
    
    params[:start] = (Time.zone.now - 30.days).to_s if params[:start].blank? and current_account.receipt_items.size > 0 
    params[:end] ||= (Time.zone.now + 1.day).midnight.to_s
    prepare_filters [:date_range]
    start_time = Time.zone.parse(params[:start])
    end_time = Time.zone.parse(params[:end])
    @receipt_item_categories = current_account.receipt_item_categories.joins('LEFT JOIN receipt_item_types j ON (receipt_item_categories.id=j.receipt_item_category_id) LEFT JOIN receipt_items i ON (j.id=i.receipt_item_type_id AND i.date BETWEEN ' + ActiveRecord::Base.sanitize(start_time) + ' AND ' + ActiveRecord::Base.sanitize(end_time) + ')').select('receipt_item_categories.id, receipt_item_categories.name, SUM(i.total) AS total').group('receipt_item_categories.id, receipt_item_categories.name').order(order)
    
    respond_with @receipt_item_categories
  end

  # GET /receipt_item_categories/1
  # GET /receipt_item_categories/1.json
  def show
    order = sortable_column_order do |column, direction|
      case column
      when 'name'
        "#{column} #{direction}"
      when 'total'
        "#{column} #{direction}"
      else
        'total DESC'
      end
    end
    
    params[:start] = (Time.zone.now - 30.days).to_s if params[:start].blank? and current_account.receipt_items.size > 0 
    params[:end] ||= (Time.zone.now + 1.day).midnight.to_s
    prepare_filters [:date_range]
    @receipt_item_category = current_account.receipt_item_categories.find(params[:id])
    @receipt_item_types = @receipt_item_category.receipt_item_types.joins(:receipt_items).where('receipt_items.date BETWEEN ? AND ?', Time.zone.parse(params[:start]), Time.zone.parse(params[:end])).select('MIN(receipt_item_types.id) AS id, friendly_name, SUM(receipt_items.total) AS total').group(:friendly_name).order(order)
    respond_with @receipt_item_category
  end

  # GET /receipt_item_categories/new
  # GET /receipt_item_categories/new.json
  def new
    @receipt_item_category = current_account.receipt_item_categories.new
    respond_with @receipt_item_category
  end

  # GET /receipt_item_categories/1/edit
  def edit
    @receipt_item_category = current_account.receipt_item_categories.find(params[:id])
  end

  # POST /receipt_item_categories
  # POST /receipt_item_categories.json
  def create
    params[:receipt_item_category].delete(:user_id) if params[:receipt_item_category]
    @receipt_item_category = current_account.receipt_item_categories.new(receipt_item_category_params)
    if @receipt_item_category.save
      add_flash :notice, t('receipt_item_category.created')
    end
    respond_with @receipt_item_category
  end

  # PUT /receipt_item_categories/1
  # PUT /receipt_item_categories/1.json
  def update
    @receipt_item_category = current_account.receipt_item_categories.find(params[:id])
    if @receipt_item_category.update_attributes(receipt_item_category_params)
      add_flash :notice, t('receipt_item_category.updated')
    end
    respond_with @receipt_item_category
  end

  # DELETE /receipt_item_categories/1
  # DELETE /receipt_item_categories/1.json
  def destroy
    @receipt_item_category = current_account.receipt_item_categories.find(params[:id])
    @receipt_item_category.destroy
    respond_with @receipt_item_category, location: receipt_item_categories_url 
  end

  private
  def receipt_item_category_params
    params.require(:receipt_item_category).permit(:name)
  end
end
