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

  # DELETE /location_histories/1
  # DELETE /location_histories/1.xml
  def destroy
    @location_history = current_account.location_histories.find(params[:id])
    @location_history.destroy
    respond_with @location_history, :location => location_histories_path
  end

end
