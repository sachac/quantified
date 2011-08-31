# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ajaxful_rating}
  s.version = "2.2.8.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Edgar J. Suarez}]
  s.date = %q{2010-08-27}
  s.description = %q{Provides a simple way to add rating functionality to your application.}
  s.email = %q{edgar.js@gmail.com}
  s.extra_rdoc_files = [%q{CHANGELOG}, %q{README.textile}, %q{lib/ajaxful_rating.rb}, %q{lib/axr/css_builder.rb}, %q{lib/axr/errors.rb}, %q{lib/axr/helpers.rb}, %q{lib/axr/locale.rb}, %q{lib/axr/model.rb}, %q{lib/axr/stars_builder.rb}]
  s.files = [%q{CHANGELOG}, %q{README.textile}, %q{lib/ajaxful_rating.rb}, %q{lib/axr/css_builder.rb}, %q{lib/axr/errors.rb}, %q{lib/axr/helpers.rb}, %q{lib/axr/locale.rb}, %q{lib/axr/model.rb}, %q{lib/axr/stars_builder.rb}]
  s.homepage = %q{http://github.com/edgarjs/ajaxful-rating}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Ajaxful_rating}, %q{--main}, %q{README.textile}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{ajaxful_rating}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Provides a simple way to add rating functionality to your application.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
