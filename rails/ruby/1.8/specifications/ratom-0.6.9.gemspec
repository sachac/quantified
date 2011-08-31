# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ratom}
  s.version = "0.6.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Peerworks}, %q{Sean Geoghegan}]
  s.date = %q{2011-07-12}
  s.description = %q{A fast Atom Syndication and Publication API based on libxml}
  s.email = %q{seangeo@gmail.com}
  s.extra_rdoc_files = [%q{LICENSE}, %q{README.rdoc}]
  s.files = [%q{LICENSE}, %q{README.rdoc}]
  s.homepage = %q{http://github.com/seangeo/ratom}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{ratom}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Atom Syndication and Publication API}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 1.1.2"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<libxml-ruby>, [">= 1.1.2"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<libxml-ruby>, [">= 1.1.2"])
  end
end
