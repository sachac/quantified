# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tzinfo}
  s.version = "0.3.29"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Philip Ross}]
  s.date = %q{2011-06-26}
  s.description = %q{TZInfo is a Ruby library that uses the standard tz (Olson) database to provide daylight savings aware transformations between times in different time zones.}
  s.email = %q{phil.ross@gmail.com}
  s.extra_rdoc_files = [%q{README}, %q{CHANGES}]
  s.files = [%q{README}, %q{CHANGES}]
  s.homepage = %q{http://tzinfo.rubyforge.org/}
  s.rdoc_options = [%q{--exclude}, %q{definitions}, %q{--exclude}, %q{indexes}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{tzinfo}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Daylight-savings aware timezone library}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
