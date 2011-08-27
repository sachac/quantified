# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{treetop}
  s.version = "1.4.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Nathan Sobo}]
  s.autorequire = %q{treetop}
  s.date = %q{2011-07-27}
  s.email = %q{cliffordheath@gmail.com}
  s.executables = [%q{tt}]
  s.extra_rdoc_files = [%q{LICENSE}, %q{README.md}]
  s.files = [%q{bin/tt}, %q{LICENSE}, %q{README.md}]
  s.homepage = %q{http://functionalform.blogspot.com}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{A Ruby-based text parsing and interpretation DSL}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<polyglot>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<i18n>, ["~> 0.5.0"])
      s.add_development_dependency(%q<rr>, ["~> 0.10.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<polyglot>, [">= 0.3.1"])
    else
      s.add_dependency(%q<polyglot>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<i18n>, ["~> 0.5.0"])
      s.add_dependency(%q<rr>, ["~> 0.10.2"])
      s.add_dependency(%q<rspec>, [">= 2.0.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<polyglot>, [">= 0.3.1"])
    end
  else
    s.add_dependency(%q<polyglot>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<i18n>, ["~> 0.5.0"])
    s.add_dependency(%q<rr>, ["~> 0.10.2"])
    s.add_dependency(%q<rspec>, [">= 2.0.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<polyglot>, [">= 0.3.1"])
  end
end
