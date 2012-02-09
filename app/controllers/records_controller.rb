class RecordsController < ApplicationController
  respond_to :html, :json, :csv
  # GET /records
  # GET /records.xml
  def index
    authorize! :view_time, current_account
    @start = (!params[:start].blank? ? Time.zone.parse(params[:start]) : ((current_account.records.minimum('timestamp') || (Time.now - 1.week)))).in_time_zone.midnight
    @end = (!params[:end].blank? ? Time.zone.parse(params[:end]) : ((current_account.records.maximum('timestamp') || Time.now) + 1.day)).in_time_zone.midnight
    
    if params[:commit] == t('records.index.recalculate_durations')
      Record.recalculate_durations(current_account, @start - 1.day, @end + 1.day)
      add_flash :notice, t('records.index.recalculated_durations')
    end
    @order = params[:order]
    if @order == 'oldest'
      @records = current_account.records.order('timestamp ASC')
    else
      @records = current_account.records.order('timestamp DESC')
    end
    @records = @records.where(:timestamp => @start..@end)
    unless params[:filter_string].blank?
      query = "%" + params[:filter_string].downcase + "%"
      @records = @records.joins(:record_category).where('LOWER(records.data) LIKE ? OR LOWER(record_categories.full_name) LIKE ?', query, query)
      unless managing?
        @records = @records.public
      end
    end
    unless html? or managing?
      @records = @records.public
    end
    respond_to do |format|
      format.html { @records = @records.paginate :page => params[:page] }
      format.json { render :json => json_paginate(@records) }
      format.csv { 
        csv_string = FasterCSV.generate do |csv|
          csv << ['start_time', 'end_time', 'record_category_name', 'record_category_id', 'duration', 'source', 'source_id', 'data']
          @records.each do |e|
            row = [e.timestamp ? l(e.timestamp, :format => :long) : '',
                   e.end_timestamp ? l(e.end_timestamp, :format => :long) : '',
                   e.record_category.full_name,
                   e.record_category_id,
                   e.duration,
                   e.source,
                   e.source_id]
            if e.data
              row += e.data.map { |k, v| [k, v]}.flatten
            end
            csv << row
          end
        end
        send_data csv_string, :type => "text/plain", :filename=>"records.csv", :disposition => 'attachment'
      }
    end
  end

  # GET /records/1
  # GET /records/1.xml
  def show
    authorize! :view_time, current_account
    @record = current_account.records.find(params[:id])
    @context = @record.context
    if html?
      @during_this = @record.during_this
    elsif @record.private?
      authorize! :manage_account, current_account
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @record }
      format.json { render :json => { :record => @record, :context => @context } }
    end
  end

  # GET /records/new
  # GET /records/new.xml
  def new
    authorize! :manage_account, current_account
    @record = current_account.records.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @record }
    end
  end

  # GET /records/1/edit
  def edit
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
  end

  # POST /records
  # POST /records.xml
  def create
    authorize! :manage_account, current_account
    @record = current_account.records.new(params[:record])

    respond_to do |format|
      if @record.save
        format.html { redirect_to(@record, :notice => 'Record was successfully created.') }
        format.xml  { render :xml => @record, :status => :created, :location => @record }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /records/1
  # PUT /records/1.xml
  def update
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])

    respond_to do |format|
      if @record.update_attributes(params[:record])
        format.html { redirect_to(@record, :notice => 'Record was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.xml
  def destroy
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    @record.destroy

    respond_to do |format|
      format.html { redirect_to(records_url) }
      format.xml  { head :ok }
    end
  end

  def clone
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    @record = @record.dup
    render 'edit'
  end

end
