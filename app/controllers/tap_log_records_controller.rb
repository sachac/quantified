class TapLogRecordsController < ApplicationController
  # GET /tap_log_records
  # GET /tap_log_records.xml
  def index
    authorize! :view_tap_log_records, current_account
    @tap_log_records = current_account.tap_log_records.order('timestamp desc')
    [:catOne, :catTwo, :catThree].each do |sym|
      unless params[sym].blank? 
        @tap_log_records = @tap_log_records.where("#{sym}=?", params[sym])
      end
    end
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
