class ClothingLogsController < ApplicationController
  # GET /clothing_logs
  # GET /clothing_logs.xml
  def index
    @clothing_logs = ClothingLog.order("date DESC").all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clothing_logs }
    end
  end

  # GET /clothing_logs/1
  # GET /clothing_logs/1.xml
  def show
    @clothing_log = ClothingLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @clothing_log }
    end
  end

  # GET /clothing_logs/new
  # GET /clothing_logs/new.xml
  def new
    @clothing_log = ClothingLog.new
    @clothing_log.date = Time.now
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clothing_log }
    end
  end

  # GET /clothing_logs/1/edit
  def edit
    @clothing_log = ClothingLog.find(params[:id])
  end

  # POST /clothing_logs
  # POST /clothing_logs.xml
  def create
    if (params[:clothing] && params[:clothing_id].blank?) then
      if params[:clothing].is_numeric? then
        @clothing = Clothing.where(:number => params[:clothing]).first
        params[:clothing_id] = @clothing.id
      else
        @clothing = Clothing.new(:name => params[:clothing], :number => Clothing.maximum(:number) + 1)
        @clothing.save
        flash[:notice] = "Saved new clothing ID #{@clothing.number}."
        params[:clothing_id] = @clothing.id
      end
    end
    if (params[:date] && params[:clothing_id]) then
      @clothing_log = ClothingLog.new(:date => params[:date], :clothing_id => params[:clothing_id])
    else
      @clothing_log = ClothingLog.new(params[:clothing_log])
    end

    respond_to do |format|
      if @clothing_log.save
        format.html { redirect_to(clothing_index_path, :notice => "Logged #{@clothing_log.date}.") }
        format.xml  { render :xml => @clothing_log, :status => :created, :location => @clothing_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @clothing_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clothing_logs/1
  # PUT /clothing_logs/1.xml
  def update
    @clothing_log = ClothingLog.find(params[:id])

    respond_to do |format|
      if @clothing_log.update_attributes(params[:clothing_log])
        format.html { redirect_to(@clothing_log, :notice => 'Clothing log was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @clothing_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clothing_logs/1
  # DELETE /clothing_logs/1.xml
  def destroy
    @clothing_log = ClothingLog.find(params[:id])
    @clothing_log.destroy

    respond_to do |format|
      format.html { redirect_to(clothing_logs_url) }
      format.xml  { head :ok }
    end
  end
end
