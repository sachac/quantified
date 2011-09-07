# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hpricot}
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{why the lucky stiff}]
  s.date = %q{2011-02-28}
  s.description = %q{a swift, liberal HTML parser with a fantastic library}
  s.email = %q{why@ruby-lang.org}
  s.extensions = [%q{ext/fast_xs/extconf.rb}, %q{ext/hpricot_scan/extconf.rb}]
  s.extra_rdoc_files = [%q{README.md}, %q{CHANGELOG}, %q{COPYING}]
  s.files = [%q{README.md}, %q{CHANGELOG}, %q{COPYING}, %q{ext/fast_xs/extconf.rb}, %q{ext/hpricot_scan/extconf.rb}]
  s.homepage = %q{http://code.whytheluckystiff.net/hpricot/}
  s.rdoc_options = [%q{--quiet}, %q{--title}, %q{The Hpricot Reference}, %q{--main}, %q{README.md}, %q{--inline-source}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{hobix}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{a swift, liberal HTML parser with a fantastic library}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
