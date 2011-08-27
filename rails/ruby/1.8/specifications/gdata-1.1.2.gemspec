# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gdata}
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jeff Fisher, Trevor Johns}]
  s.date = %q{2011-03-28}
  s.description = %q{This gem provides a set of wrappers designed to make it easy to work with 
the Google Data APIs.
}
  s.email = %q{trevorjohns@google.com}
  s.extra_rdoc_files = [%q{README}, %q{LICENSE}]
  s.files = [%q{README}, %q{LICENSE}]
  s.homepage = %q{http://code.google.com/p/gdata-ruby-util}
  s.rdoc_options = [%q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.requirements = [%q{none}]
  s.rubyforge_project = %q{gdata}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Google Data APIs Ruby Utility Library}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
