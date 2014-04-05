class Goal < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :period, :label, :expression
  attr_accessor :parsed, :expression_type, :target, :op, :op1, :op2, :val1, :val2, :record_category, :parsed

  def parse
    return self.parsed if self.parsed
    return unless self.expression
    if matches = self.expression.match(/^\[(.*?)\] *(>|<|<=|>=|=) *([0-9\.]+)/)
      self.expression_type = :direct
      self.record_category = self.user.record_categories.lookup(matches[1]).first
      self.op = matches[2]
      self.target = matches[3].to_f
    elsif matches = self.expression.match(/\[(.*?)\] *(>|<|<=|>=|=|!=) *\[(.*)\]/)
      self.expression_type = :categories
      self.record_category = self.user.record_categories.lookup(matches[1]).first
      self.op = matches[2]
      self.target = self.user.record_categories.lookup(matches[3]).first 
    elsif matches = self.expression.match(/^([\.0-9]+) *(<=?) *\[([^\]]+)\] *(<=?) *([\.0-9]+)/)
      self.expression_type = :range
      self.val1 = matches[1].to_f
      self.op1 = matches[2]
      self.record_category = self.user.record_categories.lookup(matches[3]).first
      self.op2 = matches[4]
      self.val2 = matches[5].to_f
    end
    self.parsed = true
    return self.parsed
  end

  def recreate_from_parsed
    case expression_type
    when :direct
      self.expression = "[#{self.record_category.id}] #{self.op} #{'%.2f' % self.target}"
    when :categories
      self.expression = "[#{self.record_category.id}] #{self.op} [#{self.target.id}]"
    when :range
      self.expression = "#{'%.2f' % self.val1} #{self.op1} [#{self.record_category.id}] #{self.op2} #{'%.2f' % self.val2}"
    end
  end
  
  def evaluate_direct
    return { label: 'Does not exist', performance: nil, target: nil, success: nil, text: '' } unless self.record_category
    performance = self.record_category.cumulative_time(range) / 3600.0
    target = self.target
    success = performance.send(self.op, target)
    {:label => self.label, :performance => performance, :target => target, :success => success, :text => performance ? '%.1f' % performance : ''}
  end

  def evaluate_categories
    return { label: 'Does not exist', performance: nil, target: nil, success: nil, text: '' } unless self.record_category and self.target
    operator = self.op
    time1 = (self.record_category.cumulative_time(range) / 3600.0) || 0
    time2 = (self.target.cumulative_time(range) / 3600.0) || 0
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
      case operator
      when '='
        success = delta.abs < epsilon
      when '!='
        success = delta.abs > epsilon
      when '<'
        success = delta < -epsilon
      when '>'
        success = delta > epsilon
      when '<='
        success = delta <= epsilon
      when '>='
        success = delta >= -epsilon
      end
    end
    { label: self.label, performance: performance, target: target, success: success, text: "#{self.record_category.full_name}: #{"%0.1f" % time1} - #{self.target.full_name}: #{"%0.1f" % time2}" }
  end
  
  def evaluate_range
    return { label: 'Does not exist', performance: nil, target: nil, success: nil, text: '' } unless self.record_category
    target = self.val1
    performance = (self.record_category.cumulative_time(range) / 3600.0) || 0
    performance ||= 0
    success = self.val1.send(self.op1, performance) && performance.send(self.op2, self.val2)
    {:label => self.label, :performance => performance, :target => target, :success => success, :text => performance ? '%.1f' % performance : ''}
  end
  
  def parse_expression
    p = self.parse
    case self.expression_type
    when :direct then evaluate_direct
    when :categories then evaluate_categories
    when :range then evaluate_range
    end
  end

  def set_from_form(p)
    p = HashWithIndifferentAccess.new(p)
    operators = ['<', '<=', '=', '>=', '>', '!=']
    case p[:expression_type]
    when 'direct', :direct
      self.expression_type = :direct
      self.record_category = self.user.record_categories.find_by_id(p[:direct_record_category_id])
      self.op = p[:direct_op] if operators.include?(p[:direct_op])
      self.target = p[:direct_target].to_f
    when 'categories', :categories
      self.expression_type = :categories
      self.record_category = self.user.record_categories.find_by_id(p[:categories_record_category_id])
      self.op = p[:categories_op] if operators.include?(p[:categories_op])
      self.target = self.user.record_categories.find_by_id(p[:categories_target_id])
    when 'range', :range
      self.expression_type = :range
      self.record_category = self.user.record_categories.find_by_id(p[:range_record_category_id])
      self.op1 = p[:range_op1] if operators.include?(p[:range_op1])
      self.op2 = p[:range_op2] if operators.include?(p[:range_op2])
      self.val1 = p[:range_val1].to_f
      self.val2 = p[:range_val2].to_f
    end
    if p[:active]
      self.status = Goal::ACTIVE
    else
      self.status = Goal::INACTIVE
    end
    recreate_from_parsed
  end
  
  def range
    case self.period
    when 'weekly'
      self.user.this_week
    when 'monthly'
      date = Time.zone.today
      start = Time.zone.local(date.year, date.month, 1)
      start.midnight.in_time_zone..Time.zone.now
    when 'today'
      (Time.zone.now.midnight)..Time.zone.now
    when 'daily'
      (Time.zone.now - 1.day)..Time.zone.now
    end
  end

  def self.check_goals(user)
    list = user.goals.where('status IS NULL or status != ?', Goal::INACTIVE)
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
          hash[:goal] = g
          goals[hash[:label]] = hash
        end
      rescue
        # Silently omit failing goals
      end
    end
    goals
  end

  def active?
    self.status.nil? || self.status != Goal::INACTIVE
  end

  def active=(val)
    if val
      self.status = Goal::ACTIVE
    else
      self.status = Goal::INACTIVE
    end
  end

  ACTIVE = 'active'
  INACTIVE = 'inactive'
  GOOD_COLOR = '#0c0'
  ATTENTION_COLOR = '#c00'
  
  comma do
    id
    label
    expression
    period
  end
end
