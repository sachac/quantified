# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thor}
  s.version = "0.14.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Yehuda Katz}, %q{JosÃ© Valim}]
  s.date = %q{2010-11-19}
  s.description = %q{A scripting framework that replaces rake, sake and rubigen}
  s.email = [%q{ruby-thor@googlegroups.com}]
  s.executables = [%q{rake2thor}, %q{thor}]
  s.extra_rdoc_files = [%q{CHANGELOG.rdoc}, %q{LICENSE}, %q{README.md}, %q{Thorfile}]
  s.files = [%q{bin/rake2thor}, %q{bin/thor}, %q{CHANGELOG.rdoc}, %q{LICENSE}, %q{README.md}, %q{Thorfile}]
  s.homepage = %q{http://github.com/wycats/thor}
  s.rdoc_options = [%q{--charset=UTF-8}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{A scripting framework that replaces rake, sake and rubigen}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_development_dependency(%q<rdoc>, ["~> 2.5"])
      s.add_development_dependency(%q<rake>, [">= 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.1"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.3"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3"])
      s.add_dependency(%q<rdoc>, ["~> 2.5"])
      s.add_dependency(%q<rake>, [">= 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.1"])
      s.add_dependency(%q<simplecov>, ["~> 0.3"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3"])
    s.add_dependency(%q<rdoc>, ["~> 2.5"])
    s.add_dependency(%q<rake>, [">= 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.1"])
    s.add_dependency(%q<simplecov>, ["~> 0.3"])
  end
end
