class Memory < ApplicationRecord

  acts_as_taggable_on :tags
  has_many :links
  belongs_to :user
  before_save :update_sort_time
  
  def self.parse_date(s)
    return nil if s.blank?
    month = 1
    day = 1
    year = Time.zone.now.year
    if match_data = (s.match /^([0-9][0-9][0-9][0-9])\-([0-9][0-9]?)$/) 
      year = match_data[1]
      month = match_data[2]
      return Time.zone.local(year.to_i, month.to_i, 1)
    end
    if match_data = (s.match /^([0-9][0-9][0-9][0-9])$/) 
      year = match_data[1]
      return Time.zone.local(year.to_i, 1, 1)
    end
    date = Chronic::parse(s)
    date ||= Chronic::parse("#{year}-#{month}-#{day}")
  end

  def update_sort_time
    self.sort_time = Memory.parse_date(self.date_entry)
    return true
  end
  
  def private?
    self.access != 'public'
  end

  def public?
    self.access == 'public'
  end
  fires :new, :on => :create, :actor => :user
end
