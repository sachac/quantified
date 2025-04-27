# Challenges: 
# I have to manually create my time graphs
class TimeController < ApplicationController
  skip_before_action :authenticate_user!, :only => [:index, :review, :graph, :dashboard]
  include ApplicationHelper
  respond_to :html, :xml, :json, :csv
  # POST
  def refresh_from_csv
    authorize! :manage_account, current_account
    if params[:tap_file]
      @result = Record.refresh_from_tap_log(current_account, params[:tap_file].tempfile.path)
      add_flash :notice, t('time.refreshed')
    end
    respond_with @result, location: records_path
  end 

  def refresh
    authorize! :manage_account, current_account
  end

  def review
    authorize! :view_time, current_account
    params[:start] ||= current_account.beginning_of_week.advance(:weeks => -1).strftime('%Y-%m-%d')
    params[:category_tree] ||= 'full'
    params[:end] ||= Time.zone.now.advance(:days => 1).strftime('%Y-%m-%d')
    prepare_filters [:date_range, :category_tree, :parent_id, :display_type, :zoom_level]
    @categories = current_account.record_categories.index_by(&:id)
    @summary_start = Time.zone.parse(params[:start])
    @summary_end = Time.zone.parse(params[:end])
    @category = !params[:parent_id].blank? ? current_account.record_categories.find(params[:parent_id]) : nil
    range = @summary_start..@summary_end
    # Pick the appropriate level of review
    zoom_level = params[:zoom_level] || ''
    if !zoom_level.blank? and [:daily, :weekly, :monthly, :yearly].include?(zoom_level.to_sym)
      @zoom = zoom_level.to_sym
    else
      @zoom = Record.choose_zoom_level(range)
    end
    @summary = RecordCategory.summarize(:user => current_account, :range => range, :zoom => @zoom, :parent => @category, :tree => params[:category_tree] ? params[:category_tree].to_sym : nil, :key => nil)
    respond_with({:categories => @categories, :summary => @summary})
  end

  def graph
    authorize! :view_time, current_account
    params[:start] ||= params[:url_start]
    params[:start] ||= current_account.beginning_of_week.advance(:weeks => -4).strftime('%Y-%m-%d')
    params[:end] ||= params[:url_end]
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d')
    prepare_filters [:date_range]
    @range = Time.zone.parse(params[:start]).to_date..Time.zone.parse(params[:end]).to_date
    @num_days = @range.end - @range.begin
    entries = Record.get_entries_for_time_range(current_account, @range)
    @records = Record.prepare_graph(@range, entries)
    unsorted = RecordCategory.summarize(:key => :date, :range => @range, :records => entries, :zoom => :daily, :user => current_account, :tree => :individual)[:rows]
    @categories = current_account.record_categories.index_by(&:id)
    @totals = unsorted.map { |k,v|
      if k.is_a? Date
        [k, v.sort { |a,b| (a[0].is_a?(Integer)&& b[0].is_a?(Integer)) ? @categories[a[0]].full_name <=> @categories[b[0]].full_name : 1 }]
      else
        [k, v]
      end
    }
    @data = {name: 'Time', children: Hash.new }

    # Calculate the totals needed for hierarchical display
    @category_totals = Hash.new { |h,k| h[k] = 0 }
    @total = 0
    entries.each do |x|
      @category_totals[x.record_category_id] += x.duration
      @total += x.duration
    end
    @data = {name: 'Time', children: Hash.new}
    @cumulative_totals = Hash.new { |h,k| h[k] = 0 }
    # Reconstruct the category tree
    # Goal: parent -> { label: c{ children { ... } }
    @categories.values.sort_by(&:dotted_ids).reverse.each do |x|
      start = @data
      x.dotted_ids.split(".").each do |id|
        @cumulative_totals[id.to_i] += @category_totals[x.id]
        start[:children] ||= Hash.new
        start[:total] ||= 0
        start[:total] += @category_totals[x.id]
        start[:children][id.to_i] ||= Hash.new
        start = start[:children][id.to_i]
      end
      start[:name] = x.name
      start[:label] = "#{x.name} - #{duration @cumulative_totals[x.id]} (#{'%d' % ((@cumulative_totals[x.id] * 100.0) / @total)}%) "
      start[:total] = @category_totals[x.id]
      start[:color] = x.get_color || '#ccc'
      start[:children] = start[:children].values if start[:children]
    end
    @total = duration(@total)
    @data[:label] = "Time - #{@total}"
    @data[:children] = @data[:children].values
    respond_with({:categories => @categories, :totals => @totals})
  end

  def dashboard
    authorize! :view_time, current_account
    # Display high-level categories this week: average, daily average, weekday, weekend
    @summary = RecordCategory.summarize(:user => current_account, :range => current_account.this_week, :zoom => :daily, :tree => :full)
    @week_beginning = current_account.beginning_of_week

    @current_activity = current_account.records.activities.order('timestamp DESC').first
    @categories = current_account.record_categories.index_by(&:id)
    # Display current activity
    # Display quick-entry box for tracking a new activity
    respond_with @summary
  end

  def track
    authorize! :manage_account, current_account
    category_input = params[:category] && params[:category].dup
    unless params[:category] or params[:category_id]
      go_to time_dashboard_path and return
    end
    rec = Record.parse(current_account, params)
    if category_input
      data = Record.guess_time(category_input, user: current_account)
      time = data[1]
    end
    unless params[:timestamp].blank?
      time ||= Time.zone.parse(params[:timestamp])
    end
    time ||= Time.now
    @time = time
    if request.format.html? then
      if rec.nil?
        # Could not find matching category. Offer to create?
        go_to new_record_category_path(:timestamp => time), notice: t('record_category.not_found_create') and return
      elsif rec.is_a? Record
        redirect_to edit_record_path(rec, :destination => params[:destination]) and return
      else
        redirect_to disambiguate_record_categories_path(:timestamp => time, :category => category_input), :method => :post and return
      end
    else
      if rec.nil?
        # Could not find matching category. Offer to create?
        respond_with 'error' => 'Record category not found'
      elsif rec.is_a? Record
        respond_with rec
      else
        respond_with 'error' => 'Ambiguous', 'categories' => rec
      end
    end
  end
end
