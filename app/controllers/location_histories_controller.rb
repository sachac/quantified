class LocationHistoriesController < ApplicationController
  load_and_authorize_resource
  # GET /location_histories
  # GET /location_histories.xml
  def index
    @location_histories = LocationHistory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @location_histories }
    end
  end

  # GET /location_histories/1
  # GET /location_histories/1.xml
  def show
    @location_history = LocationHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location_history }
    end
  end

  # GET /location_histories/new
  # GET /location_histories/new.xml
  def new
    @location_history = LocationHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location_history }
    end
  end

  # GET /location_histories/1/edit
  def edit
    @location_history = LocationHistory.find(params[:id])
  end

  # POST /location_histories
  # POST /location_histories.xml
  def create
    @location_history = LocationHistory.new(params[:location_history])
    @location_history.user = current_account
    respond_to do |format|
      if @location_history.save
        format.html { redirect_to(@location_history, :notice => 'Location history was successfully created.') }
        format.xml  { render :xml => @location_history, :status => :created, :location => @location_history }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /location_histories/1
  # PUT /location_histories/1.xml
  def update
    @location_history = LocationHistory.find(params[:id])

    respond_to do |format|
      if @location_history.update_attributes(params[:location_history])
        format.html { redirect_to(@location_history, :notice => 'Location history was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /location_histories/1
  # DELETE /location_histories/1.xml
  def destroy
    @location_history = LocationHistory.find(params[:id])
    @location_history.destroy

    respond_to do |format|
      format.html { redirect_to(location_histories_url) }
      format.xml  { head :ok }
    end
  end
end
