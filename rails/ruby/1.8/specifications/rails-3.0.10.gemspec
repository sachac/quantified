# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails}
  s.version = "3.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{David Heinemeier Hansson}]
  s.date = %q{2011-08-16}
  s.description = %q{Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.}
  s.email = %q{david@loudthinking.com}
  s.executables = [%q{rails}]
  s.files = [%q{bin/rails}]
  s.homepage = %q{http://www.rubyonrails.org}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{rails}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Full-stack web application framework.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["= 3.0.10"])
      s.add_runtime_dependency(%q<actionpack>, ["= 3.0.10"])
      s.add_runtime_dependency(%q<activerecord>, ["= 3.0.10"])
      s.add_runtime_dependency(%q<activeresource>, ["= 3.0.10"])
      s.add_runtime_dependency(%q<actionmailer>, ["= 3.0.10"])
      s.add_runtime_dependency(%q<railties>, ["= 3.0.10"])
      s.add_runtime_dependency(%q<bundler>, ["~> 1.0"])
    else
      s.add_dependency(%q<activesupport>, ["= 3.0.10"])
      s.add_dependency(%q<actionpack>, ["= 3.0.10"])
      s.add_dependency(%q<activerecord>, ["= 3.0.10"])
      s.add_dependency(%q<activeresource>, ["= 3.0.10"])
      s.add_dependency(%q<actionmailer>, ["= 3.0.10"])
      s.add_dependency(%q<railties>, ["= 3.0.10"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["= 3.0.10"])
    s.add_dependency(%q<actionpack>, ["= 3.0.10"])
    s.add_dependency(%q<activerecord>, ["= 3.0.10"])
    s.add_dependency(%q<activeresource>, ["= 3.0.10"])
    s.add_dependency(%q<actionmailer>, ["= 3.0.10"])
    s.add_dependency(%q<railties>, ["= 3.0.10"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
  end
end
