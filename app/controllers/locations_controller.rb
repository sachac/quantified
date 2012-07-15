class LocationsController < ApplicationController
  handles_sortable_columns
  respond_to :html, :xml, :json, :csv
  # GET /locations
  # GET /locations.xml
  def index
    authorize! :view_locations, current_account
    @locations = current_account.locations.all
    respond_with @locations
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    authorize! :view_locations, current_account
    @location = current_account.locations.find(params[:id])
    @stuff = @location.stuff
    respond_with @location
  end

  def stuff
    authorize! :view_locations, current_account
    if request.format.html?
      redirect_to location_path(params[:id])
    end
    @location = current_account.locations.find(params[:id])
    @stuff = @location.stuff
    respond_with @stuff
  end
  
  # GET /locations/new
  # GET /locations/new.xml
  def new
    authorize! :manage_account, current_account
    @location = current_account.locations.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    authorize! :manage_account, current_account
    @location = current_account.locations.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    authorize! :manage_account, current_account
    @location = current_account.locations.new(params[:location])
    @location.user = current_account
    respond_to do |format|
      if @location.save
        format.html { redirect_to(@location, :notice => 'Location was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    authorize! :manage_account, current_account
    @location = current_account.locations.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to(@location, :notice => 'Location was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    authorize! :manage_account, current_account
    @location = current_account.locations.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end
end
