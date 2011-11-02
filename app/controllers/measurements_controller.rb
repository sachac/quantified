class MeasurementsController < ApplicationController
  # GET /measurements
  # GET /measurements.xml
  def index
    @measurements = Measurement.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @measurements }
    end
  end

  # GET /measurements/1
  # GET /measurements/1.xml
  def show
    @measurement = Measurement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @measurement }
    end
  end

  # GET /measurements/new
  # GET /measurements/new.xml
  def new
    @measurement = Measurement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @measurement }
    end
  end

  # GET /measurements/1/edit
  def edit
    @measurement = Measurement.find(params[:id])
  end

  # POST /measurements
  # POST /measurements.xml
  def create
    @measurement = Measurement.new(params[:measurement])

    respond_to do |format|
      if @measurement.save
        format.html { redirect_to(@measurement, :notice => 'Measurement was successfully created.') }
        format.xml  { render :xml => @measurement, :status => :created, :location => @measurement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @measurement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /measurements/1
  # PUT /measurements/1.xml
  def update
    @measurement = Measurement.find(params[:id])

    respond_to do |format|
      if @measurement.update_attributes(params[:measurement])
        format.html { redirect_to(@measurement, :notice => 'Measurement was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measurement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /measurements/1
  # DELETE /measurements/1.xml
  def destroy
    @measurement = Measurement.find(params[:id])
    @measurement.destroy

    respond_to do |format|
      format.html { redirect_to(measurements_url) }
      format.xml  { head :ok }
    end
  end
end
