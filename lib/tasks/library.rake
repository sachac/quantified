namespace :library do
  task :refresh => :environment do
    TorontoLibrary.all.each do |l|
      l.refresh_items
    end
  end
end
