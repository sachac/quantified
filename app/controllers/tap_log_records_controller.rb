class TapLogRecordsController < ApplicationController
  # GET /tap_log_records
  # GET /tap_log_records.xml
  def index
    authorize! :view_tap_log_records, current_account
    @tap_log_records = current_account.tap_log_records.order('timestamp desc')
    @start = (!params[:start].blank? ? Time.zone.parse(params[:start]) : (current_account.time_records.maximum('end_time') || Date.today) - 1.week).in_time_zone.midnight
    @end = (!params[:end].blank? ? Time.zone.parse(params[:end]) : (current_account.time_records.maximum('end_time') || Date.tomorrow)).in_time_zone.midnight
    [:catOne, :catTwo, :catThree, :status].each do |sym|
      unless params[sym].blank? 
        @tap_log_records = @tap_log_records.where("#{sym}=?", params[sym])
      end
    end
    unless params[:filter_string].blank?
      if can? :manage_account, current_account
        @tap_log_records = @tap_log_records.where("lower(note) LIKE ?", '%' + params[:filter_string].downcase + '%')
      else
        @tap_log_records = @tap_log_records.where("lower(note) LIKE ? AND NOT lower(note) LIKE '%!private%'", '%' + params[:filter_string].downcase + '%')
      end
    end
    unless @start.blank?
      @tap_log_records = @tap_log_records.where('timestamp >= ?', @start)
    end
    unless @end.blank?
      @tap_log_records = @tap_log_records.where('timestamp <= ?', @end)
    end

    @tap_log_records = @tap_log_records.paginate :per_page => 20, :page => params[:page]
    @total_duration = @tap_log_records.sum('duration')
    min = @tap_log_records.minimum('timestamp').in_time_zone.midnight
    max = @tap_log_records.maximum('timestamp').in_time_zone.midnight
    days = (max - min) / 1.day + 1
    @average_per_day = (@total_duration || 0) / days
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tap_log_records }
    end
  end

  # GET /tap_log_records/1
  # GET /tap_log_records/1.xml
  def show
    @tap_log_record = current_account.tap_log_records.find(params[:id])
    authorize! :view, @tap_log_record
    @current_activity = @tap_log_record.current_activity
    @during_this = @tap_log_record.during_this
    @previous_activity = @tap_log_record.previous.activity.first
    @previous_entry = @tap_log_record.previous.first
    @next_activity = @tap_log_record.next.activity.first
    @next_entry = @tap_log_record.next.first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tap_log_record }
    end
  end

  # GET /tap_log_records/new
  # GET /tap_log_records/new.xml
  def new
    @tap_log_record = current_account.tap_log_records.new
    authorize! :create, @tap_log_record

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tap_log_record }
    end
  end

  # GET /tap_log_records/1/edit
  def edit
    @tap_log_record = current_account.tap_log_records.find(params[:id])
    authorize! :update, @tap_log_record
  end

  # POST /tap_log_records
  # POST /tap_log_records.xml
  def create
    @tap_log_record = current_account.tap_log_records.new(params[:tap_log_record])
    authorize! :create, @tap_log_record

    respond_to do |format|
      if @tap_log_record.save
        format.html { redirect_to(@tap_log_record, :notice => 'Tap log record was successfully created.') }
        format.xml  { render :xml => @tap_log_record, :status => :created, :location => @tap_log_record }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tap_log_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def copy_to_memory
    @tap_log_record = current_account.tap_log_records.find(params[:id])
    @tap_log_record.update_attributes(:status => 'done')

    authorize! :manage_account, current_account
    @memory = current_account.memories.new(:body => @tap_log_record.note.gsub(/ *!memory */i, ''), :access => @tap_log_record.note =~ /!private/i ? 'private' : 'public')
    render :template => 'memories/new' and return
  end

  # PUT /tap_log_records/1
  # PUT /tap_log_records/1.xml
  def update
    @tap_log_record = current_account.tap_log_records.find(params[:id])
    authorize! :update, @tap_log_record

    respond_to do |format|
      if @tap_log_record.update_attributes(params[:tap_log_record])
        format.html { redirect_to(@tap_log_record, :notice => 'Tap log record was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tap_log_record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tap_log_records/1
  # DELETE /tap_log_records/1.xml
  def destroy
    @tap_log_record = current_account.tap_log_records.find(params[:id])
    authorize! :delete, @tap_log_record
    @tap_log_record.destroy

    respond_to do |format|
      format.html { redirect_to(tap_log_records_url) }
      format.xml  { head :ok }
    end
  end
end
