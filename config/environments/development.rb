Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.eager_load = false
  
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.smtp_settings = {:enable_starttls_auto => false}


  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # Do not compress assets
  config.assets.compress = false
  
  # Expands the lines which load the assets
  config.assets.debug = true
  config.assets.digest = false
  config.log_level = :debug

  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  config.action_mailer.default_url_options = { :host => "dev.quantifiedawesome.com" }
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = false
  config.eager_load = false
  config.active_storage.service = :local
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end

ActionMailer::Base.delivery_method = :test
