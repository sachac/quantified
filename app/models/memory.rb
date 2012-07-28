class Memory < ActiveRecord::Base

  acts_as_taggable_on :tags
  has_many :links
  belongs_to :user
  before_save :update_sort_time
  
  def parse_date(s)
    return nil if s.blank?
    month = 1
    day = 1
    year = Date.today.year
    if match_data = (s.match /^([0-9][0-9][0-9][0-9])/) 
      year = match_data[1]
    end
    begin
      date = Chronic::parse(s)
    rescue
      date = Chronic::parse("#{year}-#{month}-#{day}")
    end
  end

  def update_sort_time
    self.sort_time = parse_date(self.date_entry)
    return true
  end
  
  def private?
    self.access != 'public'
  end

  def public?
    self.access == 'public'
  end
end
