class RecordsController < ApplicationController
  respond_to :html, :json, :csv, :xml
  skip_before_action :verify_authenticity_token, :only => [:create]
  # GET /records
  # GET /records.xml
  def index
    authorize! :view_time, current_account
    @start = (!params[:start].blank? ? Time.zone.parse(params[:start]) : ((current_account.records.minimum('timestamp') || (Time.now - 1.week)))).in_time_zone.midnight
    @end = (!params[:end].blank? ? Time.zone.parse(params[:end]) : ((current_account.records.maximum('timestamp') || Time.now) + 1.day)).in_time_zone.midnight
    @filter_string = (params && params[:filter_string])
    if params[:commit] == t('records.index.recalculate_durations')
      authorize! :manage_account, current_account
      Record.recalculate_durations(current_account, @start - 1.day, @end + 1.day)
      add_flash :notice, t('records.index.recalculated_durations')
    end
    @order = params[:order]
    @records = Record.get_records(current_account, :order => @order, :include_private => managing?, :start => @start, :end => @end, :filter_string => @filter_string)
    if params[:category_type]
      @records = @records.where('record_categories.category_type=?', [params[:category_type]])
    end
    if params[:count]
      @records = @records.limit(params[:count])
    end
    if request.format.csv? or request.format.json?
      if params[:split] and params[:split] == 'split'
        @records = Record.split(@records)
      end
      @data = @records
    else
      list = @records
      @records = @records.paginate :page => params[:page], :per_page => params[:per_page]
      base = @records
      @pre_split = @records
      if params[:split] and params[:split] == 'split'
        @records = Record.split(@records)
      end
      @data = { 
        :current_page => base.current_page,
        :per_page => base.per_page,
        :total_entries => list.pluck(:id).count,
        :entries => @records
      }
    end
    respond_with @data, :location => params[:destination] 
  end

  # GET /records/1
  # GET /records/1.xml
  def show
    authorize! :view_time, current_account
    @record = current_account.records.find(params[:id])
    @context = @record.context
    if @record.private?
      authorize! :manage_account, current_account
    end
    if request.format.html?
      @during_this = @record.during_this
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
    @record = current_account.records.new(record_params)
    if !params[:record][:timestamp].blank? and params[:record][:timestamp].match /^[0-9]+/  # probably a timestamp
       @record.timestamp = Time.at(params[:record][:timestamp].to_f)
    end
    if params[:data]
      @record.data = params[:data]
    end
    if @record.save
      @record.update_previous
      @record.update_next
      add_flash :notice, t('record.created')
    end
    respond_with @record
  end

  # PUT /records/1
  # PUT /records/1.xml
  def update
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    if params[:record][:end_timestamp].blank?
      params[:record].delete(:end_timestamp)
    end
    @record.assign_attributes(record_params)
    if params[:record][:data]
      @record.data = params[:record][:data]
    end
    if @record.save
      @record.update_previous
      @record.update_next
      add_flash :notice, t('record.updated')
    end
    respond_with @record
  end

  # DELETE /records/1
  # DELETE /records/1.xml
  def destroy
    authorize! :manage_account, current_account
    @record = current_account.records.find(params[:id])
    @record.destroy
    respond_with @record, :location => (params[:destination] || records_path)
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
      @records = Record.confirm_batch(account, params[:batch], :date => params[:date] ? Time.zone.parse(params[:date]) : nil)
    end
    if op == t('record.create')
      @created = Record.create_batch(account, params[:row].values.map { |r| r.symbolize_keys })
      add_flash :notice, t('record.batch')
      respond_with @created, :location => records_path
    else
      respond_with @records
    end
  end

  def help
    authorize! :manage_account, current_account
  end

  private
  def record_params
    params.require(:record).permit(:source_name, :source_id, :timestamp, :record_category_id, :end_timestamp, :duration, :date, :manual)
  end
    
end
