require 'fileutils'

plugin_dir = File.dirname(__FILE__)

%w(images stylesheets).each do |asset_dir|
  Dir.chdir(File.join(plugin_dir, 'lib', asset_dir))
  Dir['*'].each do |asset|
    file_path = File.join(RAILS_ROOT, 'public', asset_dir, asset)
    if File.exists?(file_path)
      puts "#{file_path} already exists"
    else
      FileUtils.cp(asset, file_path)
      puts "#{file_path} added"
    end
  end
end