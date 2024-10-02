# Load the rails application

require_relative 'application'
# Initialize the rails application
Rails.application.initialize!
Time.zone = "Eastern Time (US & Canada)"
#my_date_formats = { :default => '%Y-%m-%d' }
#ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_date_formats) 
#ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_date_formats) 
require 'core_extensions/object'


