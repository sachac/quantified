class CsaFoodsController < ApplicationController
  autocomplete :food, :name

  # GET /csa_foods
  # GET /csa_foods.xml
  def index
    @csa_foods = CsaFood.find(:all, :include => :food)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @csa_foods }
    end
  end

  # GET /csa_foods/1
  # GET /csa_foods/1.xml
  def show
    @csa_food = CsaFood.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @csa_food }
    end
  end

  # GET /csa_foods/new
  # GET /csa_foods/new.xml
  def new
    @csa_food = CsaFood.new
    @csa_food.date_received = Date.today
    @csa_food.unit = 'g'
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @csa_food }
    end
  end

  # GET /csa_foods/1/edit
  def edit
    @csa_food = CsaFood.find(params[:id])
  end

  # POST /csa_foods
  # POST /csa_foods.xml
  def create
    food = Food.find_by_name(params[:csa_food][:food_id])
    food = Food.find_by_name(params[:csa_food][:food_id].pluralize) unless food
    unless food
      food = Food.create(:name => params[:csa_food][:food_id])
      food.save
    end
    params[:csa_food][:food_id] = food.id
    @csa_food = CsaFood.new(params[:csa_food])
    respond_to do |format|
      if @csa_food.save
        format.html { redirect_to(new_csa_food_path, :notice => 'Csa food was successfully created.') }
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
    @csa_food = CsaFood.find(params[:id])

    respond_to do |format|
      if @csa_food.update_attributes(params[:csa_food])
        format.html { redirect_to(@csa_food, :notice => 'Csa food was successfully updated.') }
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
    @csa_food = CsaFood.find(params[:id])
    @csa_food.destroy

    respond_to do |format|
      format.html { redirect_to(csa_foods_url) }
      format.xml  { head :ok }
    end
  end
end
