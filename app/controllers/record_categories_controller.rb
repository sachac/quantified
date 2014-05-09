class RecordCategoriesController < ApplicationController
  skip_authorization_check :only => [:autocomplete_record_category_full_name]
  autocomplete :record_category, :full_name, :full => true, :scopes => [:active]
  respond_to :html, :json, :csv, :xml
  
  # GET /record_categories
  # GET /record_categories.xml
  def index
    authorize! :view_time, current_account
    if params and params[:all]
      @record_categories = current_account.record_categories.order('full_name')
    else
      @record_categories = current_account.record_categories.where('parent_id IS NULL').order('name')
    end
    respond_with @record_categories
  end

  # GET /record_categories/1
  # GET /record_categories/1.xml
  def show
    authorize! :view_time, current_account
    @record_category = current_account.record_categories.find(params[:id])
    if @record_category.active
      @title = @record_category.name
    else
      @title = @record_category.name + " (" + I18n.t('general.inactive') + ")"
    end
    if request.format.html? or request.format.csv?
      params[:order] ||= 'newest'
      @order = params[:order]
      params[:start] ||= (Time.zone.now.to_date - 1.year).midnight.to_s
      params[:end] ||= (Time.zone.now + 1.day).midnight.to_s
      prepare_filters [:date_range, :order, :filter_string, :split]
      @summary_start = Time.zone.parse(params[:start])
      @summary_end = Time.zone.parse(params[:end])
      @records = @record_category.category_records(:start => @summary_start, :end => @summary_end, :filter_string => params[:filter_string], :include_private => managing?)
      @oldest = @records.order('timestamp ASC').first
      @total_entries = @records.count
      @count_activities = @records.activities.count
      if params[:order] == 'oldest'
        @records = @records.order('timestamp ASC')
      else
        @records = @records.order('timestamp DESC')
      end
      if request.format.html?
        if @records then @records = @records.paginate :page => params[:page], :per_page => 20 end
      end
      if params[:split] and params[:split] == 'split'
        split = Record.split(@records)
        @records = split
      end 
      if request.format.html?
        @max_duration = 0
        @min_duration = nil
        @heatmap = Hash.new
        @total = 0
        
        @records.each { |x|
          next unless x.record_category.category_type == 'activity'
          if !x.end_timestamp
            x.duration = ([Time.zone.now, @summary_end].min - x.timestamp).to_i
          end
          @total = @total + x.duration

          d = ((x.duration / 3600.0) * 10.0).to_i / 10.0
          @heatmap[x.timestamp.to_i] = d
          if x.duration > @max_duration
            @max_duration = d
          end
          if @min_duration.nil? || @min_duration > d && d > 0
            @min_duration = d
          end
        }
        @min_duration ||= 0
        @step = (@max_duration - @min_duration) / 3
        @count_domain = (((@summary_end - @summary_start).to_i / 1.day) / 30) + 1
      end
      
    end

    respond_to do |format|
      format.html {  }
      format.json { render :json => @record_category }
      format.xml { render :xml => @record_category }
      format.csv {
        csv_string = CSV.generate do |csv|
          csv << [@record_category.id, @record_category.full_name]
          csv << ['start_time', 'end_time', 'record_category_name', 'record_category_id', 'duration', 'source_name', 'source_id', 'data']
          @records.each do |e|
            row = [e.timestamp ? l(e.timestamp, :format => :long) : '',
                   e.end_timestamp ? l(e.end_timestamp, :format => :long) : '',
                   e.record_category.full_name,
                   e.record_category_id,
                   e.duration,
                   e.source_name,
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

  def records
    authorize! :view_time, current_account
    @record_category = current_account.record_categories.find(params[:id])
    params[:order] ||= 'newest'
    @order = params[:order]
    @summary_start = params && params[:start] ? Time.zone.parse(params[:start]).midnight : (Time.zone.now.to_date - 1.year).midnight
    @summary_end = params && params[:end] ? Time.zone.parse(params[:end]).midnight : (Time.zone.now.to_date + 1.day).midnight
    prepare_filters [:date_range, :order, :filter_string]
    @records = @record_category.category_records(:order => @order, :start => @summary_start, :end => @summary_end, :filter_string => params[:filter_string])
    unless managing?
      @records = @records.public
    end
    unless request.format.csv?
      @records = @records.paginate :page => params[:page], :per_page => 20
      @data = { 
        :current_page => @records.current_page,
        :per_page => @records.per_page,
        :total_entries => @records.total_entries,
        :entries => @records 
      }
    end
    respond_to do |format|
      format.html { render 'show' }
      format.json { render :json => @data }
      format.xml { render :xml => @data }
      format.csv {
        csv_string = CSV.generate do |csv|
          csv << ['start_time', 'end_time', 'record_category_name', 'record_category_id', 'duration', 'source_name', 'source_id', 'data']
          @records.each do |e|
            row = [e.timestamp ? l(e.timestamp, :format => :long) : '',
                   e.end_timestamp ? l(e.end_timestamp, :format => :long) : '',
                   e.record_category.full_name,
                   e.record_category_id,
                   e.duration,
                   e.source_name,
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
  
  # GET /record_categories/new
  # GET /record_categories/new.xml
  def new
    authorize! :manage_account, current_account
    @record_category = RecordCategory.new
    @record_category.parent_id = params[:parent_id]
    @record_category.category_type = 'activity'
    @record_category.data = [{"key" => nil, "label" => nil, "type" => nil}]
    respond_with @record_category
  end

  # GET /record_categories/1/edit
  def edit
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    if @record_category.category_type != 'list'
      @record_category.data ||= Array.new
      @record_category.data << {'key' => nil, 'label' => nil, 'type' => nil}
    end
  end

  # POST /record_categories
  # POST /record_categories.xml
  def create
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.new(params[:record_category])
    params[:record_category][:data].reject! { |x| x['key'].blank? } if params[:record_category][:data]
    @record_category.data ||= Array.new
    if @record_category.save
      add_flash :notice, t('record_category.created')
    end
    if params[:timestamp]
      rec = current_account.records.create(:timestamp => Time.zone.parse(params[:timestamp]), :source_name => 'category creation', :source_id => @record_category.id, :record_category_id => @record_category.id)
      if rec.save
        rec.update_previous
        rec.update_next
      end
      respond_with rec, location: edit_record_path(rec)
    else
      respond_with @record_category
    end
  end

  # PUT /record_categories/1
  # PUT /record_categories/1.xml
  def update
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    params[:record_category][:data].reject! { |x| x['key'].blank? } if params[:record_category][:data]
    params[:record_category].delete(:user_id)
    if @record_category.update_attributes(params[:record_category])
      add_flash :notice, t('record_category.updated')
    end
    respond_with @record_category
  end

  # DELETE /record_categories/1
  # DELETE /record_categories/1.xml
  def destroy
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    @record_category.destroy
    respond_with(@record_category, :location => record_categories_url)
  end

  def track
    authorize! :manage_account, current_account
    @record_category = current_account.record_categories.find(params[:id])
    now = Time.zone.now
    rec = current_account.records.create(:timestamp => now, :source_name => 'quantified awesome record categories', :source_id => @record_category.id, :record_category_id => @record_category.id)
    if rec
      rec.update_previous
      rec.update_next
    end
    @record = rec
    respond_with rec, location: edit_record_path(rec)
  end

  def bulk_update
    authorize! :manage_account, current_account
    @list = Array.new
    if params[:category_type]
      params[:category_type].each do |k,v|
        cat = current_account.record_categories.find(k)
        cat.category_type = v
        cat.save!
        @list << cat
      end
    end
    if params[:commit] == t('records.index.recalculate_durations')
      Record.recalculate_durations(current_account)
      add_flash :notice, t('records.index.recalculated_durations')
    end
    respond_with @list, location: params[:destination] || record_categories_path
  end

  def tree
    authorize! :manage_account, current_account
    @list = current_account.record_categories.order(:full_name)
    respond_with @list
  end

  def disambiguate
    authorize! :manage_account, current_account
    category = params[:category]
    matches = category.match /^(.*)\|(.*)/
    if matches 
      category = matches[1]
      record_data = matches[2]
    end
    data = Record.guess_time(category)
    time = data[1]
    end_time = data[2]
    unless params[:timestamp].blank?
      time ||= params[:timestamp]
    end
    time ||= Time.now
    @list = RecordCategory.search(current_account, data[0])
    if @list.nil? || (!@list.is_a?(RecordCategory) && @list.size == 0)
      # No match
      go_to root_path, :error => "Could not find category matching: " + category + ". " + self.class.helpers.link_to("Create?", new_record_category_path(:category => { :name => data[0] }, :first_timestamp => time)).html_safe  and return
    elsif @list.is_a? RecordCategory
      # Just one, so track it directly
      redirect_to track_time_path(:timestamp => time, :source_name => params[:source], :destination => params[:destination], :end_timestamp => end_time) and return
    end
    # Display the list
    respond_with @list
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:user_id => current_account.id)
  end
  
end
