source 'http://rubygems.org'

gem 'rails', '~> 7.2.1'
gem 'dotenv-rails', :groups => [:development, :test]
gem 'haml-rails' # templating language
gem 'comma' # For easy CSV output
gem 'timeline_fu'
gem 'mysql2'
gem 'net-imap'
gem 'loofah', '>= 2.19.1'
gem 'nokogiri', '>= 1.4'
# gem "paperclip", ">= 2.0"
gem 'will_paginate-bootstrap'
gem 'will_paginate' # , '3.1.5'
gem 'color', '~> 1.7.1'
gem 'narray'
gem 'simple_form', '>= 5.0.3'          # easy form markup
gem 'jquery-ui-rails'
gem 'jquery-rails' # add to page
# gem 'angular_rails_csrf'
gem 'cancancan'  # permissions
gem 'rails-observers', '>= 0.1.5'      # to trigger timeline events
gem 'actionpack'
#gem 'n_gram'
#gem 'statsample'
# gem 'rails-assets-angular', :source => 'https://rails-assets.org'
# gem 'rails-assets-angular-filter', :source => 'https://rails-assets.org'
# gem 'rails-assets-angular-devise', :source => 'https://rails-assets.org'
#gem 'exception_notification', :require => 'exception_notifier'
# group :under_consideration do
#   gem 'rack-offline', :git => 'git://github.com/wycats/rack-offline.git'
#   gem 'ruby-graphviz', :git => "https://github.com/glejeune/Ruby-Graphviz.git"
  
#  # handled by bower instead?
#   gem 'gdata_19', '1.1.5'
#   gem 'workflow'
#   gem 'actionmailer-with-request'
#   gem 'subdomain-fu', :git => "git://github.com/nhowell/subdomain-fu.git"
#   gem 'passgen'
#   gem 'ruby_parser'
#   gem 'autoprefixer-rails'
#   gem 'email_validator'
# end

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
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
gem 'acts-as-taggable-on'
gem 'chronic'  # time
# gem 'acts-as-tree-with-dotted-ids'
gem 'ancestry'
gem 'nifty-generators'
gem 'devise'
#gem 'aizuchi'
#gem 'barometer'
gem 'mechanize'  # for talking to the library website
gem 'rails-settings-cached'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'sprockets'
gem 'sqlite3'

gem 'ffi', '>= 1.16.3'
group :development do
  gem 'compass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'libv8'
  gem 'therubyracer', '>= 0.12.3'
  gem 'public_suffix', '>= 5.1.1'
end

group :development, :test do
  gem 'bower-rails'
    gem 'coveralls', require: false
    gem 'rspec-rails', '~> 7.0.0'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'rails-assets-angular-mocks', :source => 'http://insecure.rails-assets.org'
  gem 'selenium-webdriver'
  gem 'forgery'
  gem 'factory_girl_rails'  
  gem 'email_spec'
    gem 'rspec-mocks'
  gem 'guard-cucumber'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'rspec-activemodel-mocks'
  gem 'spork'
  gem 'guard-rspec'
  gem 'guard-spring'
  gem 'cucumber', '>= 3.0.2'
  gem 'fakeweb'
  gem 'simplecov', :require => false
  gem 'cucumber-rails', '>= 1.8', :require => false
  gem 'capybara', '>= 3.36'
  gem 'cucumber_factory'
end
group :console do
  gem 'gem_bench', :require => false
  gem 'fastercsv'  # loading CSVs
  gem 'yaml_db'
end
