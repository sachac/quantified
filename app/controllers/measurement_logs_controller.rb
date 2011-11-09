class MeasurementLogsController < ApplicationController
  # GET /measurement_logs
  # GET /measurement_logs.xml
  def index
    @measurement_logs = current_account.measurement_logs.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @measurement_logs }
    end
  end

  # GET /measurement_logs/1
  # GET /measurement_logs/1.xml
  def show
    @measurement_log = current_account.measurement_logs.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @measurement_log }
    end
  end

  # GET /measurement_logs/new
  # GET /measurement_logs/new.xml
  def new
    @measurement_log = MeasurementLog.new
    @measurement_log.measurement_id ||= params[:measurement_id]
    @measurement_log.datetime ||= params[:datetime]
    @measurement_log.datetime ||= Time.now
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @measurement_log }
    end
  end

  # GET /measurement_logs/1/edit
  def edit
    @measurement_log = current_account.measurement_logs.find(params[:id])
  end

  # POST /measurement_logs
  # POST /measurement_logs.xml
  def create
    @measurement_log = MeasurementLog.new(params[:measurement_log])
    @measurement_log.user = current_account
    respond_to do |format|
      if @measurement_log.save
        format.html { redirect_to(measurements_path, :notice => 'Measurement log was successfully created.') }
        format.xml  { render :xml => @measurement_log, :status => :created, :location => @measurement_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @measurement_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /measurement_logs/1
  # PUT /measurement_logs/1.xml
  def update
    @measurement_log = current_account.measurement_logs.find(params[:id])

    respond_to do |format|
      if @measurement_log.update_attributes(params[:measurement_log])
        format.html { redirect_to(@measurement_log, :notice => 'Measurement log was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measurement_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /measurement_logs/1
  # DELETE /measurement_logs/1.xml
  def destroy
    @measurement_log = current_account.measurement_logs.find(params[:id])
    @measurement_log.destroy

    respond_to do |format|
      format.html { redirect_to(measurement_logs_url) }
      format.xml  { head :ok }
    end
  end
end
