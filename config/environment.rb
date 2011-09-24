# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Home::Application.initialize!
Time.zone = "Eastern Time (US & Canada)"
#my_date_formats = { :default => '%Y-%m-%d' }
#ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_date_formats) 
#ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_date_formats) 
require 'core_extensions/object'

