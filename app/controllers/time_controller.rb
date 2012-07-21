# Challenges: 
# I have to manually create my time graphs
class TimeController < ApplicationController
  respond_to :html, :xml, :json, :csv
  # POST
  def refresh_from_csv
    authorize! :manage_account, current_account
    if params[:tap_file]
      Record.refresh_from_tap_log(current_account, params[:tap_file].tempfile.path)
      add_flash :notice, t('time.refreshed')
    end
    redirect_to :action => "graph"
  end 

  def refresh
    authorize! :manage_account, current_account
  end

  def review
    authorize! :view_time, current_account
    params[:start] ||= current_account.beginning_of_week.advance(:weeks => -1).strftime('%Y-%m-%d')
    params[:category_tree] ||= 'full'
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
    prepare_filters [:date_range, :category_tree, :parent_id, :display_type]
    @categories = current_account.record_categories.index_by(&:id)
    @summary_start = Date.parse(params[:start])
    @summary_end = Date.parse(params[:end])
    # Pick the appropriate level of review
    @category = params[:parent_id] ? current_account.record_categories.find(params[:parent_id]) : nil
    range = @summary_start..@summary_end
    @zoom = Record.choose_zoom_level(range)
    @summary = RecordCategory.summarize(:user => current_account, :range => range, :zoom => @zoom, :parent => @category, :tree => params[:category_tree] ? params[:category_tree].to_sym : nil, :key => nil)
    respond_with({:categories => @categories, :summary => @summary})
  end

  def graph
    authorize! :view_time, current_account
    params[:start] ||= current_account.beginning_of_week.advance(:weeks => -4).strftime('%Y-%m-%d')
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
    prepare_filters [:date_range]
    @range = Date.parse(params[:start])..Date.parse(params[:end])
    entries = current_account.records.activities.where(:timestamp => @range).order('timestamp').includes(:record_category)
    @records = Record.prepare_graph(@range, entries)
    unsorted = RecordCategory.summarize(:key => :date, :range => @range, :records => entries, :zoom => :daily, :user => current_account, :tree => :individual)[:rows] 
    
    @categories = current_account.record_categories.index_by(&:id)
    @totals = unsorted.map { |k,v| [k, v.sort { |a,b| b[1] <=> a[1] }] }
    respond_with({:categories => @categories, :totals => @totals})
  end

  def dashboard
    authorize! :view_time, current_account
    # Display high-level categories this week: average, daily average, weekday, weekend
    @week_beginning = current_account.beginning_of_week
    @summary = RecordCategory.summarize(:user => current_account, :range => @week_beginning..Date.tomorrow, :zoom => :daily, :tree => :full)
    @current_activity = current_account.records.activities.order('timestamp DESC').first
    @categories = current_account.record_categories.index_by(&:id)
    # Display current activity
    # Display quick-entry box for tracking a new activity
    respond_with @summary
  end

  def track
    authorize! :manage_account, current_account
    category_input = params[:category]
    unless params[:category] or params[:category_id]
      add_flash :error, 'Please specify a category.'
      go_to time_dashboard_path and return
    end
    rec = Record.parse(current_account, params)
    unless params[:timestamp].blank?
      time ||= Time.zone.parse(params[:timestamp])
    end
    time ||= Time.now
    if rec.nil?
      go_to time_dashboard_path, :error => 'Could not find matching category' and return
    elsif rec.is_a? Record
      redirect_to edit_record_path(rec, :destination => params[:destination]) and return
    else
      redirect_to disambiguate_record_categories_path(:timestamp => time, :category => category_input), :method => :post and return 
    end
  end

end
