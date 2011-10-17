class HomeController < ApplicationController
  def index
    @library_items = LibraryItem.where("status = 'due' OR status IS NULL").order(:due)
    @clothing_today = ClothingLog.where('date = ?', Date.today)
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
    while day < @end
      @cat.each do |t| 
        if @time_by_day[day.strftime('%Y-%m-%d')] then
          @time_graphs[t] << (@time_by_day[day.strftime('%Y-%m-%d')][t] || 0) / 3600
        else
          @time_graphs[t] << 0
        end
      end
      day += 1.day
    end
    # Work
    # Sleep
    # Clothing
  end
end
