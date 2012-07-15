class StuffObserver < ActiveRecord::Observer
  def after_save(stuff)
    if stuff.location_id_changed? 
      LocationHistory.create(:stuff_id => stuff.id, :location => stuff.location, :datetime => Time.now, :user => stuff.user)
    end
  end
end
