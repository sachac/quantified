class MeasurementLogsController < ApplicationController
  respond_to :html, :json, :xml, :csv
  load_and_authorize_resource
  def index
    authorize! :manage_account, current_account
    @measurement_logs = MeasurementLog.joins(:measurement).where('measurements.user_id=?', current_account.id)
    respond_with @measurement_logs
  end

  def show
    respond_with @measurement_log
  end

  # GET /measurement_logs/new
  # GET /measurement_logs/new.xml
  def new
    authorize! :manage_account, current_account
    @measurement_log = MeasurementLog.new
    @measurement = current_account.measurements.find_by_id(params[:measurement_id])
    @measurement_log.measurement = @measurement
    @measurement_log.datetime ||= params[:datetime]
    @measurement_log.datetime ||= Time.now
    respond_with @measurement_log
  end

  # GET /measurement_logs/1/edit
  def edit
    respond_with @measurement_log
  end

  # POST /measurement_logs
  # POST /measurement_logs.xml
  def create
    @measurement = current_account.measurements.find(params[:measurement_log][:measurement_id])
    authorize! :manage, @measurement
    @measurement_log = @measurement.measurement_logs.new(measurement_log_params)
    if @measurement_log.save
      add_flash :notice, I18n.t('measurement_log.created')
    end
    respond_with @measurement_log
  end

  # PUT /measurement_logs/1
  # PUT /measurement_logs/1.xml
  def update
    authorize! :manage, @measurement_log.measurement
    params[:measurement_log].delete(:user_id)

    if @measurement_log.update_attributes(measurement_log_params)
      add_flash :notice, I18n.t('measurement_log.updated')
    end
    respond_with @measurement_log
  end

  # DELETE /measurement_logs/1
  # DELETE /measurement_logs/1.xml
  def destroy
    authorize! :manage, @measurement_log.measurement
    @measurement_log.destroy
    respond_to do |format|
      format.html { redirect_to(measurement_logs_url) }
      format.any  { head :ok }
    end
  end

  private
  def measurement_log_params
    params.require(:measurement_log).permit(:datetime, :notes, :value)
  end
end
