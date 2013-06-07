class CsaFoodsController < ApplicationController
  autocomplete :food, :name
  respond_to :html, :xml, :json, :csv

  # GET /csa_foods
  # GET /csa_foods.xml
  def index
    @csa_foods = current_account.csa_foods.includes(:food).order('date_received DESC, disposition ASC')
    authorize! :view_food, current_account
    respond_with @csa_foods
  end

  def bulk_update
    authorize! :manage_account, current_account
    if params[:bulk]
      params[:bulk].each do |key, val|
        current_account.csa_foods.find(key).update_attributes(:disposition => val)
      end
    end
    redirect_to csa_foods_path
  end
  # GET /csa_foods/1
  # GET /csa_foods/1.xml
  def show
    @csa_food = current_account.csa_foods.find(params[:id])
    authorize! :view, @csa_food
    respond_with @csa_food
  end

  # GET /csa_foods/new
  # GET /csa_foods/new.xml
  def new
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.new
    @csa_food.date_received = Time.zone.now.to_date
    @csa_food.unit = 'g'
    respond_with @csa_food
  end

  # GET /csa_foods/1/edit
  def edit
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.find(params[:id])
  end

  # POST /csa_foods
  # POST /csa_foods.xml
  def create
    authorize! :manage_account, current_account
    @csa_food = CsaFood.log(current_account, 
                            :food => params[:csa_food][:food_id], 
                            :quantity => params[:csa_food][:quantity], 
                            :unit => params[:csa_food][:unit],
                            :date_received => params[:csa_food][:date_received] || Time.zone.now.to_date)
    if result
      add_flash :notice, 'Logged.'
    end
    respond_with @csa_food, :location => new_csa_food_path
  end

  # PUT /csa_foods/1
  # PUT /csa_foods/1.xml
  def update
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.find(params[:id])
    if @csa_food.update_attributes(params[:csa_food])
      add_flash :notice, 'CSA food successfully updated.'
    end
    respond_with @csa_food, :location => csa_foods_path
  end

  # DELETE /csa_foods/1
  # DELETE /csa_foods/1.xml
  def destroy
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.find(params[:id])
    @csa_food.destroy
    respond_with @csa_food, :location => csa_foods_url
  end

  def quick_entry
    authorize! :manage_account, current_account
    @log = CsaFood.log(current_account, 
                       :food => params[:food], 
                       :quantity => params[:quantity].to_f, 
                       :unit => params[:unit],
                       :date_received => Time.zone.parse(params[:date]))
    if @log
      add_flash :notice, 'Food successfully logged.'
      respond_with @log, :location => csa_foods_path(:date => params[:date])
    else
      respond_with :error, :location => csa_foods_path(:date => params[:date])
    end
  end
end
