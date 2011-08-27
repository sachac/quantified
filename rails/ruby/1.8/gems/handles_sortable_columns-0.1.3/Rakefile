require "rake/rdoctask"
require "yaml"

GEM_NAME = "handles_sortable_columns"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = GEM_NAME
    gem.summary = "Sortable Table Columns"
    gem.description = gem.summary
    gem.email = "alex.r@askit.org"
    gem.homepage = "http://github.com/dadooda/handles_sortable_columns"
    gem.authors = ["Alex Fortuna"]
    gem.files = FileList[
      "[A-Z]*",
      "*.gemspec",
      "init.rb",
      "lib/**/*.rb",
    ]
  end
rescue LoadError
  STDERR.puts "This gem requires Jeweler to be built"
end

desc "Rebuild gemspec and package"
task :rebuild => [:gemspec, :build]

desc "Push (publish) gem to RubyGems (aka Gemcutter)"
task :push => :rebuild do
  # NOTE: Yet found no way to ask Jeweler forge a complete version string for us.
  h = YAML.load_file("VERSION.yml")
  version = [h[:major], h[:minor], h[:patch], h[:build]].compact.join(".")
  pkgfile = File.join("pkg", "#{GEM_NAME}-#{version}.gem")
  Kernel.system("gem", "push", pkgfile)
end

desc "Generate RDoc documentation"
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.title    = "Handles::SortableColumns"
  #rdoc.options << "--line-numbers"
  #rdoc.options << "--inline-source"
  rdoc.rdoc_files.include("lib/**/*.rb")
end

desc "Compile README preview"
task :readme do
  require "kramdown"

  doc = Kramdown::Document.new(File.read "README.md")

  fn = "README.html"
  puts "Writing '#{fn}'..."
  File.open(fn, "w") do |f|
    f.write(File.read "dev/head.html")
    f.write(doc.to_html)
  end
  puts ": ok"
end
