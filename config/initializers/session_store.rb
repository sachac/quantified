# Be sure to restart your server when you modify this file.

if Rails.env.production?
  Rails.application.config.session_store :cookie_store, :key => 'quantifiedawesome', :domain => '.quantifiedawesome.com'
else
  Rails.application.config.session_store :cookie_store, :key => 'quantifiedawesome', :domain => :all
end
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Home::Application.config.session_store :active_record_store
