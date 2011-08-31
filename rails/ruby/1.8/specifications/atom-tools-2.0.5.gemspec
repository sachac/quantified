# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{atom-tools}
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Brendan Taylor}]
  s.date = %q{2010-08-31}
  s.description = %q{atom-tools is an all-in-one Atom library. It parses and builds Atom (RFC 4287) entries and feeds, and manipulates Atom Publishing Protocol (RFC 5023) Collections.

It also comes with a set of commandline utilities for working with AtomPub Collections.

It is not the fastest Ruby Atom library, but it is comprehensive and makes handling extensions to the Atom format very easy.}
  s.email = %q{whateley@gmail.com}
  s.extra_rdoc_files = [%q{README}]
  s.files = [%q{README}]
  s.homepage = %q{http://github.com/bct/atom-tools/wikis}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{ibes}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Tools for working with Atom Entries, Feeds and Collections.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
