class CsaFoodsController < ApplicationController
  autocomplete :food, :name

  # GET /csa_foods
  # GET /csa_foods.xml
  def index
    @csa_foods = current_account.csa_foods.includes(:food).order('date_received DESC, disposition ASC')
    authorize! :view_food, @csa_foods
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @csa_foods }
    end
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
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @csa_food }
    end
  end

  # GET /csa_foods/new
  # GET /csa_foods/new.xml
  def new
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.new
    @csa_food.date_received = Date.today
    @csa_food.unit = 'g'
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @csa_food }
    end
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
                            :date_received => params[:csa_food][:date_received] || Date.today)
    respond_to do |format|
      if result
        format.html { redirect_to(new_csa_food_path, :notice => 'Logged.') }
        format.xml  { render :xml => @csa_food, :status => :created, :location => @csa_food }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @csa_food.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /csa_foods/1
  # PUT /csa_foods/1.xml
  def update
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.find(params[:id])

    respond_to do |format|
      if @csa_food.update_attributes(params[:csa_food])
        format.html { redirect_to(csa_foods_path, :notice => 'Csa food was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @csa_food.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /csa_foods/1
  # DELETE /csa_foods/1.xml
  def destroy
    authorize! :manage_account, current_account
    @csa_food = current_account.csa_foods.find(params[:id])
    @csa_food.destroy

    respond_to do |format|
      format.html { redirect_to(csa_foods_url) }
      format.xml  { head :ok }
    end
  end

  def quick_entry
    authorize! :manage_account, current_account
    @log = CsaFood.log(current_account, 
                       :food => params[:food], 
                       :quantity => params[:quantity].to_f, 
                       :unit => params[:unit],
                       :date_received => Date.parse(params[:date]))
    if @log
      redirect_to csa_foods_path, :notice => 'Food successfully logged.' and return
    else
#      flash[:error] = 'Could not log food.'
      redirect_to csa_foods_path(:date => params[:date]) and return
    end
  end
end
