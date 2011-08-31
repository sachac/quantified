class WeeklyCalendar::Builder
  include ::ActionView::Helpers::TagHelper

  def initialize(objects, template, options, start_date, end_date)
    raise ArgumentError, "WeeklyBuilder expects an Array but found a #{objects.inspect}" unless objects.is_a? Array
    @objects, @template, @options, @start_date, @end_date = objects, template, options, start_date, end_date
  end
  
  def days      
    concat(tag("div", :class => "days"))
      concat(content_tag("div", "Weekly View", :class => "placeholder"))
      for day in @start_date..@end_date        
        concat(tag("div", :class => "day"))
        concat(content_tag("b", day.strftime('%A')))
        concat(tag("br"))
        concat(day.strftime('%B %d'))
        concat("</div>")
      end
    concat("</div>")
  end
  
  def week(options = {})    
    days
    if options[:business_hours] == "true" or options[:business_hours].blank?
      hours = ["6am","7am","8am","9am","10am","11am","12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm"]
      header_row = "header_row"
      day_row = "day_row"
      grid = "grid"
      start_hour = 6
      end_hour = 20
    else
      hours = ["1am","2am","3am","4am","5am","6am","7am","8am","9am","10am","11am","12pm","1pm","2pm","3pm","4pm","5pm","6pm","7pm","8pm","9pm","10pm","11pm","12am"]
      header_row = "full_header_row"
      day_row = "full_day_row"
      grid = "full_grid"
      start_hour = 1
      end_hour = 24
    end
    
    concat(tag("div", :class => "hours"))
      concat(tag("div", :class => header_row))
        for hour in hours
          header_box = "<b>#{hour}</b>".html_safe
          concat(content_tag("div", header_box, :class => "header_box"))
        end
      concat("</div>")
      
      concat(tag("div", :class => grid))
        for day in @start_date..@end_date 
          concat(tag("div", :class => day_row))
          for event in @objects
            if event.start_time.strftime('%j').to_s == day.strftime('%j').to_s 
             if event.start_time.strftime('%H').to_i >= start_hour and event.end_time.strftime('%H').to_i <= end_hour
                concat(tag("div", :class => "week_event", :style =>"left:#{left(event.start_time,options[:business_hours])}px;width:#{width(event.start_time,event.end_time)}px;", :onclick => "location.href='/events/#{event.id}';"))
                  truncate = truncate_width(width(event.start_time,event.end_time))
                  yield(event,truncate)
                concat("</div>")
              end
            end
          end
          concat("</div>")
        end
      concat("</div>")
    concat("</div>")
  end
  
  private
  
  def concat(tag)
    @template.safe_concat(tag)
    ""
  end

  def left(start_time,business_hours)
    if business_hours == "true" or business_hours.blank?
      minutes = start_time.strftime('%M').to_f * 1.25
      hour = start_time.strftime('%H').to_f - 6
    else
      minutes = start_time.strftime('%M').to_f * 1.25
      hour = start_time.strftime('%H').to_f
    end
    left = (hour * 75) + minutes
  end

  def width(start_time,end_time)
    #example 3:30 - 5:30
    start_hours = start_time.strftime('%H').to_i * 60 # 3 * 60 = 180
    start_minutes = start_time.strftime('%M').to_i + start_hours # 30 + 180 = 210
    end_hours = end_time.strftime('%H').to_i * 60 # 5 * 60 = 300
    end_minutes = end_time.strftime('%M').to_i + end_hours # 30 + 300 = 330
    difference =  (end_minutes.to_i - start_minutes.to_i) * 1.25 # (330 - 180) = 150 * 1.25 = 187.5
    #unless difference < 60
      width = difference - 12
    #else
    #  width = 63.0 #default width (75px minus padding+border)
    #end
  end

  def truncate_width(width)
    hours = width / 63.0
    truncate_width = 20 * hours
  end 
end
