class MeasurementLog < ActiveRecord::Base
  belongs_to :measurement
  after_save :update_measurement
  after_destroy :update_measurement
  def update_measurement
    x = self.measurement
    x.average = x.measurement_logs.average('value')
    x.min = x.measurement_logs.minimum('value')
    x.max = x.measurement_logs.maximum('value')
    x.sum = x.measurement_logs.sum('value')
    x.save
  end
end
