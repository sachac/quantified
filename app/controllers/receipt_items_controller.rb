class ReceiptItemsController < ApplicationController
  respond_to :html, :xml, :json, :csv
  before_filter :authenticate_managing!
  
  # GET /receipt_items
  # GET /receipt_items.json
  def index
    @receipt_items = current_account.receipt_items
    respond_with @receipt_items
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
end
