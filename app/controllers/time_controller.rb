# Challenges: 
# I have to manually create my time graphs
class TimeController < ApplicationController
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
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
    prepare_filters [:date_range, :category_tree, :parent_id]
    @categories = current_account.record_categories
    @summary_start = Date.parse(params[:start])
    @summary_end = Date.parse(params[:end])
    # Pick the appropriate level of review
    @category = params[:parent_id] ? current_account.record_categories.find(params[:parent_id]) : nil
    range = @summary_start..@summary_end
    @zoom = Record.choose_zoom_level(range)
    @summary = RecordCategory.summarize(:user => current_account, :range => range, :zoom => @zoom, :parent => @category, :tree => params[:category_tree] ? params[:category_tree].to_sym : nil)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @record_categories }
    end
  end

  def graph
    authorize! :view_time, current_account
    params[:start] ||= current_account.beginning_of_week.advance(:weeks => -1).strftime('%Y-%m-%d')
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
    prepare_filters [:date_range]
    @range = Date.parse(params[:start])..Date.parse(params[:end])
    entries = current_account.records.activities.where(:timestamp => @range).order('timestamp').includes(:record_category)
    @records = Record.prepare_graph(@range, entries)
  end

  def dashboard
    authorize! :view_time, current_account
    # Display high-level categories this week: average, daily average, weekday, weekend
    @week_beginning = current_account.beginning_of_week
    @summary = RecordCategory.summarize(:user => current_account, :range => @week_beginning..Date.tomorrow, :zoom => :daily, :tree => :full)
    @current_activity = current_account.records.activities.order('timestamp DESC').first
    # Display current activity
    # Display quick-entry box for tracking a new activity
  end

  def track
    authorize! :manage_account, current_account
    unless params[:category] or params[:category_id]
      add_flash :error, 'Please specify a category.'
      go_to time_dashboard_path and return
    end
    # Look for the category
    now = params[:timestamp] ? Time.zone.parse(params[:timestamp]) : Time.now
    if params[:category_id]
      cat = current_account.record_categories.find_by_id(params[:category_id])
      rec = Record.create(:user => current_account, :record_category => cat, :timestamp => params[:timestamp] ? Time.zone.parse(params[:timestamp]) : Time.now)
      rec.update_previous
    elsif params[:category]
      rec = Record.create_from_query(current_account, params[:category], :timestamp => params[:timestamp])
      rec.update_previous
    end
    if rec.nil?
      go_to time_dashboard_path, :error => 'Could not find matching category' and return
    elsif rec.is_a? Record
      redirect_to edit_record_path(rec, :destination => params[:destination]) and return
    else
      redirect_to disambiguate_record_categories_path(:timestamp => now, :category => params[:category]), :method => :post and return 
    end
  end
end
