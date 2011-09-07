# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fastercsv}
  s.version = "1.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{James Edward Gray II}]
  s.date = %q{2011-01-07}
  s.description = %q{FasterCSV is intended as a complete replacement to the CSV standard library. It
is significantly faster and smaller while still being pure Ruby code. It also
strives for a better interface.
}
  s.email = %q{james@grayproductions.net}
  s.extra_rdoc_files = [%q{AUTHORS}, %q{COPYING}, %q{README}, %q{INSTALL}, %q{TODO}, %q{CHANGELOG}, %q{LICENSE}]
  s.files = [%q{AUTHORS}, %q{COPYING}, %q{README}, %q{INSTALL}, %q{TODO}, %q{CHANGELOG}, %q{LICENSE}]
  s.homepage = %q{http://fastercsv.rubyforge.org}
  s.rdoc_options = [%q{--title}, %q{FasterCSV Documentation}, %q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{fastercsv}
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{FasterCSV is CSV, but faster, smaller, and cleaner.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
