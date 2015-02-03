source 'http://rubygems.org'
source 'https://rails-assets.org'

gem 'rails', '~> 4.1'
gem 'haml-rails', '~> 0.4'  # templating language
gem 'comma' # For easy CSV output
gem 'timeline_fu', :git => 'https://github.com/jamesgolick/timeline_fu.git'  # for viewing events in a timeline
gem 'rake'
gem 'mysql2'
gem "paperclip", ">= 2.0"
gem 'will_paginate-bootstrap'
gem 'color'
gem 'narray'
gem 'simple_form'          # easy form markup
gem 'jquery-rails', '~> 2.1.4' # add to page
gem 'rails4-autocomplete'
gem 'handles_sortable_columns'
gem 'angular_rails_csrf'
gem 'cancancan', '~> 1.9'  # permissions
gem 'rails-observers'      # to trigger timeline events
#gem 'n_gram'
#gem 'statsample'
gem 'exception_notification', '~> 4', :require => 'exception_notifier'
group :under_consideration do
  gem 'rack-offline', :git => 'git://github.com/wycats/rack-offline.git'
  gem 'ruby-graphviz', :git => "https://github.com/glejeune/Ruby-Graphviz.git"
  gem 'rails-assets-angular' # handled by bower instead?
  gem 'gdata_19', '1.1.5'
  gem 'workflow'
  gem 'actionmailer-with-request'
  gem 'subdomain-fu', :git => "git://github.com/nhowell/subdomain-fu.git"
  gem 'passgen'
  gem 'ruby_parser'
  gem 'autoprefixer-rails'
  gem 'email_validator'
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
gem 'acts-as-taggable-on', :git => 'git://github.com/mbleigh/acts-as-taggable-on.git'
gem 'chronic'  # time
gem 'acts-as-tree-with-dotted-ids', :git => 'https://github.com/tma/acts-as-tree-with-dotted-ids.git'
gem 'nifty-generators'
gem 'devise', '~> 3.4.0'
gem 'devise_invitable'
#gem 'aizuchi'
gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'omniauth-openid'
#gem 'barometer'
gem 'mechanize'  # for talking to the library website
gem 'rails-settings-cached', '~> 0.4'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'sass-rails', '~> 4.0.2'
gem 'sprockets', '~> 2.11.0'

group :development do
  gem 'compass-rails', '~> 1.1.2'
  gem 'coffee-rails', '~> 4'
  gem 'uglifier'
  gem 'libv8', '~> 3.11'
  gem 'therubyracer', '~> 0.11.4'
end

group :development, :test do
  gem 'bower-rails'
  gem 'rspec-rails'
  gem 'coveralls', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'rails-assets-angular-mocks'
  gem 'selenium-webdriver'
  gem 'forgery'
  gem 'factory_girl_rails'  
  gem 'email_spec'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'guard-cucumber'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'rspec-activemodel-mocks'
  gem 'timecop'
  gem 'spork'
  gem 'guard-rspec'
  gem 'guard-spring'
  gem 'cucumber'
  gem 'fakeweb'
  gem 'simplecov', '>= 0.8', :require => false
  gem 'cucumber-rails', :require => false
  gem 'capybara'
  gem 'cucumber_factory', :git => 'https://github.com/makandra/cucumber_factory.git'
end
group :console do
  gem 'gem_bench', :require => false
  gem 'fastercsv'  # loading CSVs
  gem 'yaml_db'
end

