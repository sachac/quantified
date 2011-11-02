class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  def index
    @pickup_count = TorontoLibrary.sum('pickup_count')
    @library_items = LibraryItem.where("status = 'due' OR status IS NULL OR status = 'read'").order(:due, :status)
    if cannot? :view_all, LibraryItem then
      @library_items.where('public=1')
    end
    @clothing_today = ClothingLog.where('date = ?', Date.today)
    if current_user then
      @memento_mori = current_user.memento_mori
      @yesterday = Day.yesterday
      @today = Day.today
    else
      @memento_mori = User.find(1).memento_mori
    end
  end
  def summary
    @start = (!params[:start].blank? ? Time.parse(params[:start]) : Date.new(Date.today.year, Date.today.month, 1)).midnight
    @end = (!params[:end].blank? ? Time.parse(params[:end]) : Date.new(Date.today.year, Date.today.month + 1, 1)).midnight
    @log = TimeTrackerLog.new
    @entries = @log.entries(@start, @end)
    @time_by_day = @log.by_day(@entries)
    day = @start
    @time_graphs = Hash.new
    @cat = (@time_by_day.map { |x,y| y.keys }).flatten.uniq
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
          cat = nil
          time = (@time_by_day[day.strftime('%Y-%m-%d')][t] || 0) / 3600
          @time_graphs[t] << time
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
        else
          @time_graphs[t] << 0
        end
      end
      day += 1.day
    end
    
    # Summarize weekends and weekdays

  end
end
