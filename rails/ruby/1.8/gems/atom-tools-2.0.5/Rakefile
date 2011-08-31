require "rake"
require "rake/testtask"
require "rake/rdoctask"
require "rake/gempackagetask"
require "spec/rake/spectask"

require "rake/clean"

NAME = "atom-tools"
VERS = "2.0.5"

task :default => [:spec]

# For historical reasons, atom-tools has both rspec specs and test/unit tests.
# This is silly (and there's a lot of duplication), but I have better things to
# do than rewrite the tests.
#
# Ideally all the tests should be runnable with one command, but for now you
# have to run "rake test" and "rake spec"

# spec task
desc 'Run all specs (see also "test" task)'
Spec::Rake::SpecTask.new('spec')

# test task
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.title = 'atom-tools documentation'
  rdoc.main = 'README'
  rdoc.rdoc_files.include 'README', 'lib/**/*.rb'
  rdoc.rdoc_dir = 'doc'
end

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERS
  s.platform = Gem::Platform::RUBY
  s.author = "Brendan Taylor"
  s.email = 'whateley@gmail.com'
  s.homepage = 'http://github.com/bct/atom-tools/wikis'

  s.rubyforge_project = 'ibes'

  s.summary = 'Tools for working with Atom Entries, Feeds and Collections.'
  s.description = 'atom-tools is an all-in-one Atom library. It parses and builds Atom (RFC 4287) entries and feeds, and manipulates Atom Publishing Protocol (RFC 5023) Collections.

It also comes with a set of commandline utilities for working with AtomPub Collections.

It is not the fastest Ruby Atom library, but it is comprehensive and makes handling extensions to the Atom format very easy.'

  s.test_file = "test/runtests.rb" # TODO: should have the spec here instead?
  s.has_rdoc = true
  s.extra_rdoc_files = [ "README" ]

  s.files = %w(COPYING README Rakefile setup.rb) +
  Dir.glob("{bin,doc,test,spec,lib}/**/*") +
  Dir.glob("ext/**/*.{h,c,rb}") +
  Dir.glob("examples/**/*.rb") +
  Dir.glob("tools/*.rb")

  s.require_path = "lib"
  s.extensions = FileList["ext/**/extconf.rb"].to_a

  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
end

task :install do
  sh %{rake package}
  sh %{gem install pkg/#{NAME}-#{VERS}}
end
