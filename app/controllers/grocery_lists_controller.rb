class GroceryListsController < ApplicationController
  respond_to :html, :xml, :json, :csv
  load_and_authorize_resource except: [:index]
  
  before_action :set_grocery_list, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :manage_account, current_account
    @grocery_lists = GroceryList.lists_for(current_account)
    respond_with(@grocery_lists)
  end

  def show
  end

  
  def items_for
    @items = @grocery_list.grocery_list_items.joins('LEFT JOIN receipt_item_categories ON grocery_list_items.receipt_item_category_id=receipt_item_categories.id').includes(:receipt_item_category).select('grocery_list_items.id, grocery_list_items.name, grocery_list_items.status, grocery_list_items.quantity, receipt_item_category_id, receipt_item_categories.name AS category')
    respond_with @items
  end
  

  def new
    @grocery_list = current_account.grocery_lists.new
    respond_with(@grocery_list)
  end

  def edit
  end

  def quick_add_to
    if @grocery_list
      item = @grocery_list.grocery_list_items.find_by(name: params[:quick_add])
      if item
        add_flash :notice, t('grocery_list_item.already_added', item: params[:quick_add])
      else
        item = @grocery_list.grocery_list_items.new
        item.name = params[:quick_add]
        if item.save
          add_flash :notice, t('grocery_list_item.added', item: params[:quick_add])
        else
          add_flash :error, t('grocery_list_item.error.adding', item: params[:quick_add])
        end
      end
      respond_with item, location: params[:destination] || grocery_list_path(@grocery_list)
    end
  end
  
  def create
    @grocery_list = current_account.grocery_lists.new(grocery_list_params)
    add_email_to_list(@grocery_list, params[:email]) if params[:email]
    add_flash(:notice, 'GroceryList was successfully created.') if @grocery_list.save
    respond_with(@grocery_list)
  end

  def update
    add_email_to_list(@grocery_list, params[:email]) if params[:email]
    add_flash(:notice, 'GroceryList was successfully updated.') if @grocery_list.update(grocery_list_params)
    respond_with(@grocery_list)
  end

  def destroy
    @grocery_list.destroy
    respond_with(@grocery_list)
  end

  def unshare
    if @grocery_list.grocery_list_users.where(user_id: params[:user_id]).destroy_all
      add_flash(:notice, 'Removed.')
    end
    respond_with @grocery_list, location: edit_grocery_list_path(@grocery_list), action: :edit
  end
  
  private
    def add_email_to_list(list, email)
      user = User.find_by(email: email)
      if user.nil?
        add_flash :error, I18n.t('grocery_lists.user_not_found', email: email)
      else
        if GroceryListUser.create(grocery_list: list, user: user)
          add_flash :notice, I18n.t('grocery_lists.user_added', email: email)
        else
          add_flash :error, I18n.t('general.error.unknown')
        end
      end
    end
    
    def set_grocery_list
      @grocery_list = GroceryList.find(params[:id])
    end

    def grocery_list_params
      params.require(:grocery_list).permit(:user_id, :name)
    end
end
