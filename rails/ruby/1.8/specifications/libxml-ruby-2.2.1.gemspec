# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{libxml-ruby}
  s.version = "2.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Ross Bamform}, %q{Wai-Sun Chia}, %q{Sean Chittenden}, %q{Dan Janwoski}, %q{Anurag Priyam}, %q{Charlie Savage}]
  s.date = %q{2011-08-14}
  s.description = %q{    The Libxml-Ruby project provides Ruby language bindings for the GNOME
    Libxml2 XML toolkit. It is free software, released under the MIT License.
    Libxml-ruby's primary advantage over REXML is performance - if speed
    is your need, these are good libraries to consider, as demonstrated
    by the informal benchmark below.
}
  s.extensions = [%q{ext/libxml/extconf.rb}]
  s.files = [%q{ext/libxml/extconf.rb}]
  s.homepage = %q{http://xml4r.github.com/libxml-ruby}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Ruby Bindings for LibXML2}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
