# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{warden}
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Daniel Neighman}]
  s.date = %q{2011-07-26}
  s.email = %q{has.sox@gmail.com}
  s.extra_rdoc_files = [%q{LICENSE}, %q{README.textile}]
  s.files = [%q{LICENSE}, %q{README.textile}]
  s.homepage = %q{http://github.com/hassox/warden}
  s.rdoc_options = [%q{--charset=UTF-8}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{warden}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Rack middleware that provides authentication for rack applications}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
  end
end
