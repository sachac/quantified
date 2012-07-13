class ClothingLogsController < ApplicationController
  # GET /clothing_logs
  # GET /clothing_logs.xml
  before_filter :authenticate_user!, :except => [:index, :show, :by_date]
  def index
    authorize! :view_clothing, current_account
    params[:start] ||= current_account.beginning_of_week.advance(:weeks => -4).strftime('%Y-%m-%d')
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
    prepare_filters [:date_range]
    @range = Date.parse(params[:start])..Date.parse(params[:end])
    @clothing_logs = current_account.clothing_logs.where(:date => @range).includes(:clothing).order("date DESC, outfit_id DESC, clothing.clothing_type")
    @by_date = Hash.new
    @clothing_logs.each do |l|
      @by_date[l.date] ||= Array.new
      @by_date[l.date] << l
    end
    @dates = @by_date.keys.sort { |a,b| b  <=> a }
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clothing_logs }
    end
  end

  # GET /clothing_logs/1
  # GET /clothing_logs/1.xml
  def show
    @clothing_log = current_account.clothing_logs.find(params[:id])
    authorize! :view, @clothing_log

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @clothing_log }
    end
  end

  # GET /clothing_logs/new
  # GET /clothing_logs/new.xml
  def new
    authorize! :create, ClothingLog
    @clothing_log = current_account.clothing_logs.new
    @clothing_log.date = Time.now
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clothing_log }
    end
  end

  # GET /clothing_logs/1/edit
  def edit
    @clothing_log = current_account.clothing_logs.find(params[:id])
    authorize! :update, @clothing_log
  end

  # POST /clothing_logs
  # POST /clothing_logs.xml
  def create
    authorize! :create, ClothingLog
    if (params[:clothing] && params[:clothing_id].blank?) then
      if params[:clothing].is_numeric? then
        @clothing = Clothing.where(:id => params[:clothing]).first
        params[:clothing_id] = @clothing.id
      else
        @clothing = Clothing.new(:name => params[:clothing])
        @clothing.user_id = current_account.id
        @clothing.save
        flash[:notice] = "Saved new clothing ID #{@clothing.id}."
        params[:clothing_id] = @clothing.id
      end
    end
    if (params[:date] && params[:clothing_id]) then
      @clothing_log = current_account.clothing_logs.new(:date => params[:date], :clothing_id => params[:clothing_id])
    else
      @clothing_log = current_account.clothing_logs.new(params[:clothing_log])
    end
    @clothing_log.user_id = current_account.id
    params[:outfit_id] ||= 1
    @clothing_log.outfit_id = params[:outfit_id]
    respond_to do |format|
      if @clothing_log.save
        format.html { redirect_to(:back, :notice => "Logged #{@clothing_log.date}.") }
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
    @clothing_log = current_account.clothing_logs.find(params[:id])
    authorize! :update, @clothing_log

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
    @clothing_log = current_account.clothing_logs.find(params[:id])
    authorize! :destroy, @clothing_log
    @clothing_log.destroy

    respond_to do |format|
      format.html { redirect_to(clothing_logs_url) }
      format.xml  { head :ok }
    end
  end

  def by_date
    authorize! :view_clothing_logs, current_account
    @date = Date.parse(params[:date])
    @clothing_logs = current_account.clothing_logs.where('date = ?', @date).includes(:clothing).order('outfit_id, clothing.clothing_type')
    @previous_date = @date - 1.day
    @next_date = @date + 1.day
  end
end
