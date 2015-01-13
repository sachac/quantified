
if defined?(Bundler)
  Class.new Rails::Railtie do
    console do |app|
      Bundler.require(:console)
      #Irbtools.add_package :more # adds this extension package
                                 # here you can edit which libraries get loaded. See the irbtools README for details.
      #Irbtools.start
 
      #require 'ext/hacks/console'
      #Rails::ConsoleMethods.send :include, Hacks::Console
    end
  end
  groups = {
    # If you precompile assets before deploying to production, use this line
    assets:     %w(development test),
    monitoring: %w(staging production),
    security_analysis: %w(development test),
  }
  # List the groups that are always loaded, followed by the ones that are selectively loaded based on environment
  Bundler.require(:default, :assets, Rails.env, *Rails.groups(groups))
  #Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end
