class TimeController < ApplicationController
  def index
    @log = TimeTrackerLog.new
    @limits = {"this_week" => [Chronic.parse("last Saturday").midnight, Time.now],
      "last_week" => [Chronic.parse("last Saturday").midnight - 1.week,
                      Chronic.parse("last Saturday").midnight],
      "other_week" => [Chronic.parse("last Saturday").midnight - 2.weeks,
                       Chronic.parse("last Saturday").midnight - 1.week]}
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
  end

  def graph
    @width = 1200
    @height = 500
    @time_bottom = @height 
    @start = (!params[:start].blank? ? Time.parse(params[:start]) : Date.new(Date.today.year, Date.today.month, 1)).midnight
    @end = (!params[:end].blank? ? Time.parse(params[:end]) : Date.new(Date.today.year, Date.today.month + 1, 1)).midnight
    entries = TimeRecord.find(:all, :conditions => ["start_time >= ? AND start_time < ?", @start, @end], :order => "start_time")
    total_time = (@end - @start).to_f
    @distribution = Array.new
    @day_width = ((@width - 10) / 2) * 86400.0 / (@end.midnight - @start.midnight)
    @second_height = @time_bottom / 86400.0
    days = Hash.new
    @totals = Hash.new
    entries.each do |e|
      x = @day_width * ((e.start_time.midnight - @start.midnight) / 86400.0)
      y = @second_height * (e.start_time - e.start_time.midnight)
      item_height = @second_height * (e.end_time - e.start_time)
      if e.name == "Sleep" then
        next
      elsif e.name == "Work" then
        color = "#85acaa"
      elsif e.name.match(/^Disc/) then
        color = "#83b877"
      elsif e.name.match(/^Routine/) then
        color = "#dd9843"
      end
      class_name = e.name.downcase.gsub(/[^a-z]/, '')
      title = "#{e.start_time.strftime('%Y-%m-%d %H:%M')} - #{e.end_time.strftime('%H:%M')} #{e.name}" 
      @distribution << { :x => x, :y => y, :height => item_height, 
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
      @totals[e.name][:value] += (e.end_time - e.start_time)
    end
    @totals.each do |name,val|
      @totals[name][:percent] = @totals[name][:value] * 100.0 / total_time
    end
    @distribution_offset = @width / 2;
    @days = Array.new
    days.each do |k, vals|
      x = @distribution_offset + @day_width * ((k.midnight - @start.midnight) / 86400.0)
      y = @time_bottom
      vals = vals.sort { |a,b| a[0] <=> b[0] }
      vals.each do |name,hash|
        height = @second_height * hash[:value]
        y = y - height
        hash[:height] = height
        hash[:y] = y
        hash[:x] = x
        hash[:title] = hash[:title] + " (#{"%.1f%%" % (@totals[hash[:title]][:percent])})"
        @days << hash
      end     
    end

  end
end
