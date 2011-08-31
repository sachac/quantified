class TimeRecord < ActiveRecord::Base
  def starts_at
    @start_time
  end
  def ends_at
    @end_time
  end

end
