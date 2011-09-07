# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{workflow}
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Vladimir Dobriakov}]
  s.date = %q{2011-08-19}
  s.description = %q{    Workflow is a finite-state-machine-inspired API for modeling and interacting
    with what we tend to refer to as 'workflow'.

    * nice DSL to describe your states, events and transitions
    * robust integration with ActiveRecord and non relational data stores
    * various hooks for single transitions, entering state etc.
    * convenient access to the workflow specification: list states, possible events
      for particular state
}
  s.email = %q{vladimir@geekq.net}
  s.extra_rdoc_files = [%q{README.markdown}]
  s.files = [%q{README.markdown}]
  s.homepage = %q{http://www.geekq.net/workflow/}
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{workflow}
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{A replacement for acts_as_state_machine.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
