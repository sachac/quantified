class GroceryListsController < ApplicationController
  respond_to :html, :xml, :json, :csv
  load_and_authorize_resource
  before_action :set_grocery_list, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :manage_account, current_account
    @grocery_lists = current_account.grocery_lists
    respond_with(@grocery_lists)
  end

  def show
    respond_with(@grocery_list)
  end

  def new
    @grocery_list = current_account.grocery_lists.new
    respond_with(@grocery_list)
  end

  def edit
  end

  def quick_add_to
    if @grocery_list
      item = @grocery_list.grocery_list_items.new
      item.name = params[:quick_add]
      if item.save
        flash[:notice] = t('grocery_list_item.added', item: params[:quick_add])
      else
        flash[:error] = t('grocery_list_item.error.adding', item: params[:quick_add])
      end
      redirect_to params[:destination] || grocery_list_path(@grocery_list)
    end
  end
  
  def create
    @grocery_list = current_account.grocery_lists.new(grocery_list_params)
    flash[:notice] = 'GroceryList was successfully created.' if @grocery_list.save
    respond_with(@grocery_list)
  end

  def update
    flash[:notice] = 'GroceryList was successfully updated.' if @grocery_list.update(grocery_list_params)
    respond_with(@grocery_list)
  end

  def destroy
    @grocery_list.destroy
    respond_with(@grocery_list)
  end

  private
    def set_grocery_list
      @grocery_list = GroceryList.find(params[:id])
    end

    def grocery_list_params
      params.require(:grocery_list).permit(:user_id, :name)
    end
end
