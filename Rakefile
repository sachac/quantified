# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
include Rake::DSL
if Rails.env.development? or Rails.env.testing? then
  require 'dotenv/tasks'
  require 'coveralls/rake/task'
end
Home::Application.load_tasks

if Rails.env.testing? then
  Coveralls::RakeTask.new
end
task :test_with_coveralls => [:spec, :features, 'coveralls:push']
