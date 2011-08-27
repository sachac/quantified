# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{polyglot}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Clifford Heath}]
  s.date = %q{2011-07-27}
  s.description = %q{
The Polyglot library allows a Ruby module to register a loader
for the file type associated with a filename extension, and it
augments 'require' to find and load matching files.}
  s.email = [%q{clifford.heath@gmail.com}]
  s.extra_rdoc_files = [%q{README.txt}]
  s.files = [%q{README.txt}]
  s.homepage = %q{http://github.com/cjheath/polyglot}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Augment 'require' to load non-Ruby file types}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
