class Goal < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :period, :label, :expression

  def parse_expression
    range = self.range
    
    if matches = self.expression.match(/^\[(.*)\] *(>|<|<=|>=|=) *([0-9]+)/)
      cat = self.user.record_categories.find_by_full_name matches[1]
      if cat
        performance = cat.cumulative_time(range) / 3600.0
        target = matches[3].to_f
        success = performance.send(matches[2], target)
      else
        Rails.logger.info "Could not find #{matches[1]}"
      end
      {:label => self.label, :performance => performance, :target => target, :success => success, :text => performance ? '%.1f' % performance : ''}
    elsif matches = self.expression.match(/\[(.*)\] *(>|<|<=|>=|=) \[(.*)\]/)
        cat1 = self.user.record_categories.find_by_full_name matches[1]
        cat2 = self.user.record_categories.find_by_full_name matches[3]
        time1 = cat1.cumulative_time(range) / 3600.0
        time2 = cat2.cumulative_time(range) / 3600.0
        delta = (time1 - time2)
        percentage = delta / [time1, time2].max
        epsilon = 0.10
        performance = percentage
        target = 0
        case matches[2]
        when '<': success = delta < -epsilon
        when '=': success = delta.abs < epsilon
        when '>': success = delta > -epsilon
        when '<=': success = delta <= epsilon
        when '>=': success = delta >= -epsilon
        when '!=': success = delta.abs > epsilon
        end
        {:label => self.label, :performance => performance, :target => target, :success => success, :text => "#{matches[1]}: #{"%0.1f" % time1} - #{matches[3]}: #{"%0.1f" % time2}"}
    elsif matches = self.expression.match(/^([0-9]+) *< *\[(.*)\] *< *([0-9]+)/)
      cat = self.user.record_categories.find_by_full_name(matches[2])
      val1 = matches[1].to_f
      val2 = matches[3].to_f
      target = val1
      performance = cat.cumulative_time(range) / 3600.0
      success = (val1 < performance) && (performance < val2)
      {:label => self.label, :performance => performance, :target => target, :success => success, :text => performance ? '%.1f' % performance : ''}
    end
  end

  def range
    case self.period
    when 'weekly'
      self.user.week
    when 'monthly'
      date = Date.yesterday
      start = new Date(date.year, date.month, 1)
      start.midnight.in_time_zone..Time.now
    when 'daily'
      (Time.now - 1.day)..Time.now
    end
  end
end
