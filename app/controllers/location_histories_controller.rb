class LocationHistoriesController < ApplicationController
  load_and_authorize_resource
  respond_to :html, :xml, :json, :csv
  # GET /location_histories
  # GET /location_histories.xml
  def index
    @location_histories = current_account.location_histories
    if request.format.csv?
      @data = @location_histories
    else
      @location_histories = @location_histories.paginate :page => params[:page] 
      @data = { 
        :current_page => @location_histories.current_page,
        :per_page => @location_histories.per_page,
        :total_entries => @location_histories.total_entries,
        :entries => @location_histories
      }
    end
    respond_with @data
  end

  # GET /location_histories/1
  # GET /location_histories/1.xml
  def show
    @location_history = current_account.location_histories.find(params[:id])
    respond_with @location_history
  end

  # GET /location_histories/new
  # GET /location_histories/new.xml
  def new
    @location_history = current_account.location_histories.new
    respond_with @location_history
  end

  # GET /location_histories/1/edit
  def edit
    @location_history = current_account.location_histories.find(params[:id])
    respond_with @location_history
  end

  # POST /location_histories
  # POST /location_histories.xml
  def create
    @location_history = current_account.location_histories.new(params[:location_history])
    @location_history.user = current_account
    add_flash :notice => 'Location history was successfully created.' if @location_history.save
    respond_with @location_history
  end

  # PUT /location_histories/1
  # PUT /location_histories/1.xml
  def update
    @location_history = current_account.location_histories.find(params[:id])
    add_flash :notice => 'Location history was successfully updated.' if @location_history.update_attributes(params[:location_history])
    respond_with @location_history
  end

  # DELETE /location_histories/1
  # DELETE /location_histories/1.xml
  def destroy
    @location_history = current_account.location_histories.find(params[:id])
    @location_history.destroy
    respond_with @location_history, :location => location_histories_url
  end
end
