class RecordsController < ApplicationController
  respond_to :html, :json, :csv, :xml
  skip_before_filter :verify_authenticity_token, :only => [:create]
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
    @records = Record.get_records(current_account, :order => @order, :include_private => managing?, :start => @start, :end => @end)
    if request.format.csv?
      if params[:split] and params[:split] == 'split'
        @records = Record.split(@records)
      end
      @data = @records
    else
      @records = @records.paginate :page => params[:page] 
      list = @records
      if params[:split] and params[:split] == 'split'
        list = Record.split(@records)
      end
      @data = { 
        :current_page => @records.current_page,
        :per_page => @records.per_page,
        :total_entries => @records.total_entries,
        :entries => list
      }
    end
    respond_with @data
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
    respond_with({ :record => @record, :context => @context })
  end

  # GET /records/new
  # GET /records/new.xml
  def new
    authorize! :manage_account, current_account
    @record = current_account.records.new
    respond_with @record
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
    if params[:record][:timestamp].match /^[0-9]+/  # probably a timestamp
       params[:record][:timestamp] = Time.at(params[:record][:timestamp].to_f)
    end
    @record = current_account.records.new(params[:record])
    if @record.save
      @record.update_previous
      @record.update_next
      add_flash :notice, 'Record was successfully created.'
    end
    respond_with @record
  end

  # PUT /records/1
  # PUT /records/1.xml
  def update
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    if params[:record][:end_timestamp].blank?
      params[:record][:end_timestamp] = nil
    end
    if @record.update_attributes(params[:record])
      @record.update_previous
      @record.update_next
      add_flash :notice, 'Record was successfully updated.'
    end
    respond_with @record
  end

  # DELETE /records/1
  # DELETE /records/1.xml
  def destroy
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    @record.destroy
    respond_with @record, :location => records_url
  end

  def clone
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    @record = @record.dup
    respond_with @record
  end

  def batch
    account = current_account
    authorize! :manage_account, account
    op = params[:commit]
    if params[:batch]
      @records = Record.confirm_batch(account, params[:batch], :date => params[:date] ? Date.parse(params[:date]) : nil)
    end
    if op == "Create records"
      @created = Record.create_batch(account, params[:row].values.map { |r| r.symbolize_keys })
      add_flash :notice, 'Records created.'
      respond_with @created, :location => records_path
    else
      respond_with @records
    end
  end

  def help
    authorize! :manage_account, current_account
  end
end
