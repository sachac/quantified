require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)

module Home
  class Application < Rails::Application
    if (Rails.env.development? || Rails.env.test?) 
      Dotenv.load Rails.root.join('.env')
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
    if Rails.configuration.respond_to?(:sass)
      config.sass.load_paths << File.expand_path('../../lib/assets/stylesheets/')
      config.sass.load_paths << File.expand_path('../../vendor/assets/stylesheets/')
    end

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    config.active_record.observers = :stuff_observer
    config.to_prepare do
      Devise::SessionsController.layout "sign"
    end
    config.active_record.yaml_column_permitted_classes = [ActionController::Parameters]
    ActionDispatch::Callbacks.after do
      # Reload the factories
      if (Rails.env.test?) and FactoryGirl.factories.blank? # first init will load factories, this should only run on subsequent reloads
        FactoryGirl.factories.clear
        FactoryGirl.sequences.clear
        FactoryGirl.find_definitions
      end
    end
    config.active_support.cache_format_version = 6.1
  end
end
