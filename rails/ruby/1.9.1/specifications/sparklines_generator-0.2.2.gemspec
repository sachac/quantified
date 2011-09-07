# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sparklines_generator}
  s.version = "0.2.2"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Geoffrey Grosenbach}]
  s.autorequire = %q{sparklines_generator}
  s.cert_chain = nil
  s.date = %q{2005-08-01}
  s.email = %q{boss@topfunky.com}
  s.homepage = %q{http://nubyonrails.topfunky.com}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{Sparklines generator makes a Rails controller and helper for making small graphs in your web pages. See examples at http://nubyonrails.topfunky.com}

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sparklines>, ["> 0.0.0"])
    else
      s.add_dependency(%q<sparklines>, ["> 0.0.0"])
    end
  else
    s.add_dependency(%q<sparklines>, ["> 0.0.0"])
  end
end
