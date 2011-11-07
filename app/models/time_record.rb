class TimeRecord < ActiveRecord::Base
  belongs_to :user
  def starts_at
    @start_time
  end
  def ends_at
    @end_time
  end

end
