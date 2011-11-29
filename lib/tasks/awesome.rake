namespace :awesome do
  task :copy => :environment do
    Rails.env = 'production'
    Rake::Task["db:data:dump"].invoke
    Rails.env = 'development'
    Rake::Task["db:data:load"].invoke
  end
end
