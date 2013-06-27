class TapLogRecord < ActiveRecord::Base
  belongs_to :user
  validates :timestamp, :presence => true
  validates :catOne, :presence => true
  before_save :set_defaults
  def set_defaults
    self.timestamp ||= Time.now
    self.duration = self.end_timestamp - self.timestamp if self.end_timestamp
    true
  end
  def time_category
    cat = nil
    case self.catOne
    when 'Discretionary'
      cat = 'D - ' + self.catTwo
    when 'Personal'
      cat = 'P - ' + self.catTwo
    when 'Unpaid work'
      cat = 'UW - ' + self.catTwo
    when 'Work'
      cat = 'A - Work'
    when 'Sleep'
      cat = 'A - Sleep'
    end
    cat
  end

  def to_s
    "#{self.timestamp}\t#{self.time_category}\t#{self.catOne}\t#{self.catTwo}\t#{self.catThree}"
  end
  def category_string
    [self.catOne, self.catTwo, self.catThree].compact.join ' > '
  end
  def private?
    (self.note || '').downcase =~ /!private/
  end
  def public?
    !private?
  end
  # Return the Tap Log Record representing an activity during which this record occurred
  def current_activity
    if self.entry_type == 'activity'
      self
    else
      self.user.tap_log_records.where('timestamp < ? AND entry_type = ?', self.timestamp, 'activity').order('timestamp desc').limit(1).first
    end
  end

  def during_this
    if self.end_timestamp
      self.user.tap_log_records.where('timestamp >= ? and timestamp < ? and id != ?', self.timestamp, self.end_timestamp, self.id).order('timestamp')
    else
      self.user.tap_log_records.where('timestamp >= ? and id != ?', self.timestamp, self.id).order('timestamp')
    end
  end

  scope :activity, where('entry_type=?', 'activity')

  def previous
    self.user.tap_log_records.where('timestamp <= ? and id < ?', self.timestamp, self.id).order('timestamp desc, id desc').limit(1)
  end

  def next
    self.user.tap_log_records.where('timestamp >= ? and id > ?', self.timestamp, self.id).order('timestamp asc, id asc').limit(1) 
  end
end
