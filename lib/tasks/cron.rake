task :cron => :environment do 
  # Update library information
  @today = Day.today
  @today.library_checked_out = LibraryItem.where('status = ?', 'due').length
  @today.library_pickup = TorontoLibrary.sum('pickup_count')
  @today.save
end
