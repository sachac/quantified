class Goal < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :period, :label, :expression

  def parse_expression
    range = self.range
    
    if matches = self.expression.match(/^\[(.*)\] *(>|<|<=|>=|=) *([0-9\.]+)/)
      cat = self.user.record_categories.lookup(matches[1]).first
      if cat
        performance = cat.cumulative_time(range) / 3600.0
        target = matches[3].to_f
        success = performance.send(matches[2], target)
      else
        Rails.logger.info "Could not find #{matches[1]}"
      end
      {:label => self.label, :performance => performance, :target => target, :success => success, :text => performance ? '%.1f' % performance : ''}
    elsif matches = self.expression.match(/\[(.*)\] *(>|<|<=|>=|=|!=) *\[(.*)\]/)
      operator = matches[2]
      cat1 = self.user.record_categories.lookup(matches[1]).first
      cat2 = self.user.record_categories.lookup(matches[3]).first
      time1 = cat1.cumulative_time(range) / 3600.0 if cat1
      time2 = cat2.cumulative_time(range) / 3600.0 if cat2
      time1 ||= 0
      time2 ||= 0
      performance = 0
      target = 0
      if (time1 == 0 and time2 == 0)
        success = (operator == "=") || (operator == ">=") || (operator == "<=")
      elsif time2 == 0
        success = (operator == ">=") || (operator == ">") || (operator == "!=")
      else  
        percentage = time1 / time2
        delta = (percentage - 1) # if A < B, this is a negative percentage
        epsilon = 0.05
        performance = percentage
        target = 1
        case matches[2]
        when '<'
          success = delta < -epsilon
        when '='
          success = delta.abs < epsilon
        when '>'
          success = delta > epsilon
        when '<='
          success = delta <= epsilon
        when '>='
          success = delta >= -epsilon
        when '!='
          success = delta.abs > epsilon
        end
      end
      {:label => self.label, :performance => performance, :target => target, :success => success, :text => "#{matches[1]}: #{"%0.1f" % time1} - #{matches[3]}: #{"%0.1f" % time2}"}
    elsif matches = self.expression.match(/^([\.0-9]+) *(<=?) *\[([^\]]+)\] *(<=?) *([\.0-9]+)/)
      cat = self.user.record_categories.lookup(matches[3]).first
      val1 = matches[1].to_f
      val2 = matches[5].to_f
      op1 = matches[2]
      op2 = matches[4]
      target = val1
      performance = cat.cumulative_time(range) / 3600.0 if cat
      performance ||= 0
      success = val1.send(op1, performance) && performance.send(op2, val2)
      {:label => self.label, :performance => performance, :target => target, :success => success, :text => performance ? '%.1f' % performance : ''}
    end
  end

  def range
    case self.period
    when 'weekly'
      self.user.this_week
    when 'monthly'
      date = Time.zone.today.yesterday
      start = Time.zone.local(date.year, date.month, 1)
      start.midnight.in_time_zone..Time.zone.now
    when 'today'
      (Time.zone.now.midnight)..Time.zone.now
    when 'daily'
      (Time.zone.now.midnight - 1.day)..Time.zone.today.midnight
    end
  end

  def self.check_goals(user)
    list = user.goals
    goals = Hash.new
    list.each do |g|
      begin
        hash = g.parse_expression
        if hash
          if hash[:success] 
            hash[:class] = 'good'
            hash[:performance_color] = Goal::GOOD_COLOR
          else
            hash[:class] = 'attention'
            hash[:performance_color] = Goal::ATTENTION_COLOR
          end
          goals[hash[:label]] = hash
        end
      rescue
        # Silently omit failing goals
      end
    end
    goals
  end

  GOOD_COLOR = '#0c0'
  ATTENTION_COLOR = '#c00'
  
  comma do
    id
    label
    expression
    period
  end
end
