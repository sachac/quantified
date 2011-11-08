# Challenges: 
# I have to manually create my time graphs
class TimeController < ApplicationController
  before_filter :authenticate_user!, :except => [:graph]
  def refresh
    # Challenge: Time Recording does not update old Google Calendar entries when you rename tasks
    # Approach: Upload work unit CSV and replace entries covering that span of time
  end

  # POST
  def refresh_from_csv
    @log = TimeTrackerLog.new(current_account)
    @log.login
    @log.refresh_from_csv(params[:file].tempfile)
    redirect_to :action => "graph"
  end 

  def index
    @log = TimeTrackerLog.new(current_account)
    base = Chronic.parse("last Saturday").midnight
    @limits = {"this_week" => [base, base + 1.week],
      "last_week" => [base - 1.week, base],
      "other_week" => [base - 2.weeks, base - 1.week]}
    if params[:refresh] && @limits[params[:refresh]]
      @log.login
      @log.refresh(@limits[params[:refresh]][0], @limits[params[:refresh]][1])
      redirect_to "/time" and return
    end
    @summary = Hash.new
    # Current week
    @limits.each do |k,l|
      @summary[k] = @log.summarize(l[0], l[1])
    end
    if params[:format] == 'org'
      render "index_org"
    else
      render "index"
    end
  end

  def graph
    @day_height = 15;
    @width = 900
    @time_bottom = @height
    @start = (!params[:start].blank? ? Time.parse(params[:start]) : Date.new(Date.today.year, Date.today.month, 1)).midnight
    @end = (!params[:end].blank? ? Time.parse(params[:end]) : Date.tomorrow).midnight
    @height = (@day_height * (@end - @start) / 86400.0).to_i
    entries = current_account.time_records.find(:all, :conditions => ["start_time >= ? AND start_time < ?", @start, @end], :order => "start_time")
    total_time = (@end - @start).to_f
    @time_records = Array.new
    @day_height = (@height * 86400.0) / (@end.midnight - @start.midnight)
    @second_width = (@width / 2 - 5) / 86400.0
    days = Hash.new
    @totals = Hash.new
    entries.each do |e|
      x = ((@second_width * (e.start_time - e.start_time.midnight))).to_i
      y = ((@day_height * (e.start_time.midnight - @start.midnight) / 86400.0)).to_i
      item_width = @second_width * (e.end_time - e.start_time)
      class_name = e.name.downcase.gsub(/[^a-z]/, '')
      if e.name == "A - Sleep" then
        next
      elsif e.name == "A - Work" then
        color = "#85acaa"
      elsif e.name.match(/^D - /) then
        color = "#c2d6cb"
      elsif e.name.match(/^UW - /) then
        color = "#dd9843"
      elsif e.name.match(/^P - /) then
        color = "#acaa85"
      end
      title = "#{e.start_time.strftime('%Y-%m-%d %H:%M')} - #{e.end_time.strftime('%H:%M')} #{e.name}" 
      @time_records << { :x => x, :y => y, :width => item_width, 
        :color => color,
        :name => e.name,
        :class => class_name,
        :title => title}
      days[e.start_time.midnight] ||= Hash.new
      days[e.start_time.midnight][e.name] ||= Hash.new
      days[e.start_time.midnight][e.name][:title] = e.name
      days[e.start_time.midnight][e.name][:color] = color
      days[e.start_time.midnight][e.name][:class] = class_name
      days[e.start_time.midnight][e.name][:value] ||= 0
      days[e.start_time.midnight][e.name][:value] += (e.end_time - e.start_time)
      @totals[e.name] ||= Hash.new
      @totals[e.name][:value] ||= 0
      @totals[e.name][:color] = color
      @totals[e.name][:class] = class_name
      @totals[e.name][:title] = e.name
      @totals[e.name][:value] += (e.end_time - e.start_time)
    end
    @totals.each do |name,val|
      @totals[name][:percent] = @totals[name][:value] * 100.0 / total_time
      @totals[name][:title] +=  " (#{"%.1f%%" % (@totals[name][:percent])})"
    end
    @distribution_offset = @width / 2;
    @days = Array.new
    # Sort by name
    keys = @totals.keys.sort
    days.each do |k, vals|
      x = @distribution_offset
      y = @day_height * ((k.midnight - @start.midnight) / 86400.0)
      keys.each do |name|
        hash = vals[name]
        if hash
          width = @second_width * hash[:value]
          hash[:width] = width
          hash[:y] = y
          hash[:x] = x
          hash[:title] = k.strftime("%Y-%m-%d") + " - " + hash[:title] + " (#{"%.1f%%" % (@totals[hash[:title]][:percent])})"
          @days << hash
          x = x + width
          puts "#{k} #{x} #{width} #{hash[:title]}"
        end
      end     
    end
    @labels = Array.new
    keys.each do |name|
      if !name.blank? then
        @labels << "<a href=\"#\" class=\"#{@totals[name][:class]}\">#{@totals[name][:title]}</a>".html_safe
      end
    end
    @log = TimeTrackerLog.new(current_account)
    @time_by_day = @log.by_day(entries)
    day = @start
    @time_graphs = Hash.new
    @cat = keys
    @cat << "A - Sleep"
    @cat.each do |t| @time_graphs[t] = Array.new end
    @by_day = Hash.new
    @count_days = Hash.new
    ['Work', 'Sleep', 'Discretionary', 'Unpaid work', 'Personal care'].each do |x|
      @by_day[x] ||= Hash.new
    end
    while day < @end
      @count_days[day.wday] ||= 0
      @count_days[day.wday] += 1
      @cat.each do |t|
        if @time_by_day[day.strftime('%Y-%m-%d')] then
          @time_graphs[t] << (@time_by_day[day.strftime('%Y-%m-%d')][t] || 0) / 3600
        else
          @time_graphs[t] << 0
        end
        if @time_by_day[day.strftime('%Y-%m-%d')] then
          cat = nil
          time = (@time_by_day[day.strftime('%Y-%m-%d')][t] || 0) / 3600
          if t.match /^A - Work/ 
            cat = 'Work'
          elsif t.match /^A - Sleep/ 
            cat = 'Sleep'
          elsif t.match /^D - / 
            cat = 'Discretionary'
          elsif t.match /^UW - / 
            cat = 'Unpaid work'
          elsif t.match /^P - / 
            cat = 'Personal care'
          end
          if cat
            @by_day[cat][day.wday] ||= 0
            @by_day[cat][day.wday] += time
          end
        end
      end
      day += 1.day
    end
  end
end
