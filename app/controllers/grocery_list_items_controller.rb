class GroceryListItemsController < ApplicationController
  before_action :set_grocery_list_item, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xml, :json, :csv

  load_and_authorize_resource :except => [:index, :new, :create]

  def index
    authenticate_managing!
    @grocery_list_items = GroceryListItem.joins(:grocery_list).where('grocery_lists.user_id=?', current_account.id)
    
    respond_with(@grocery_list_items)
  end

  def show
    @price_history = @grocery_list_item.price_history.order('date DESC')
    respond_with(@grocery_list_item)
  end

  def new
    authenticate_managing!
    @grocery_list_item = GroceryListItem.new
    respond_with(@grocery_list_item)
  end

  def edit
  end

  def create
    authenticate_managing!
    @grocery_list_item = GroceryListItem.new(grocery_list_item_params)
    flash[:notice] = 'GroceryListItem was successfully created.' if @grocery_list_item.save
    respond_with(@grocery_list_item)
  end

  def update
    flash[:notice] = 'GroceryListItem was successfully updated.' if @grocery_list_item.update(grocery_list_item_params)
    respond_with(@grocery_list_item)
  end

  def destroy
    @grocery_list_item.destroy
    respond_with(@grocery_list_item)
  end

  private
    def set_grocery_list_item
      @grocery_list_item = GroceryListItem.find(params[:id])
    end

    def grocery_list_item_params
      params.require(:grocery_list_item).permit(:name, :grocery_list_id, :quantity, :status, :category)
    end
end
