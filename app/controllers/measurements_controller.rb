class MeasurementsController < ApplicationController
  respond_to :html, :json, :xml, :csv
  load_and_authorize_resource
  # GET /measurements
  # GET /measurements.xml
  def index
    @measurements = current_account.measurements.all
    respond_with @measurements
  end

  # GET /measurements/1
  # GET /measurements/1.xml
  def show
    @measurement = current_account.measurements.find(params[:id])
    respond_with @measurement
  end

  # GET /measurements/new
  # GET /measurements/new.xml
  def new
    @measurement = current_account.measurements.new
    respond_with @measurement
  end

  # GET /measurements/1/edit
  def edit
    @measurement = current_account.measurements.find(params[:id])
    respond_with @measurement
  end

  # POST /measurements
  # POST /measurements.xml
  def create
    @measurement = current_account.measurements.new(params[:measurement])
    if @measurement.save
      add_flash :notice, I18n.t('measurement.created')
    end
    respond_with @measurement
  end

  # PUT /measurements/1
  # PUT /measurements/1.xml
  def update
    @measurement = current_account.measurements.find(params[:id])
    params[:measurement].delete(:user_id)

    if @measurement.update_attributes(params[:measurement])
      add_flash :notice, I18n.t('measurement.updated')
    end
    respond_with @measurement
  end

  # DELETE /measurements/1
  # DELETE /measurements/1.xml
  def destroy
    @measurement = current_account.measurements.find(params[:id])
    @measurement.destroy
    respond_to do |format|
      format.html { redirect_to(measurements_url) }
      format.any  { head :ok }
    end
  end
end
