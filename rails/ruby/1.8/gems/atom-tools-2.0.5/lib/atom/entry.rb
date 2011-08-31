require "rexml/document"

require "atom/element"
require "atom/text"

require 'atom/feed'

module Atom
  # this is just a forward declaration since atom/entry includes atom/feed and vice-versa.
  class Feed < Atom::Element # :nodoc:
  end

  class Source < Atom::Feed
    is_atom_element :source

    # TODO: this shouldn't be necessary, but on_init doesn't get inherited the
    # way I would like it to.
    @on_init = Atom::Feed.instance_variable_get '@on_init'
  end

  class Control < Atom::Element
    attr_accessor :draft

    is_element PP_NS, :control

    on_parse [PP_NS, 'draft'] do |e,x|
      e.set(:draft, x.text == 'yes')
    end

    on_build do |e,x|
      unless (v = e.get(:draft)).nil?
        el = e.append_elem(x, ['app', PP_NS], 'draft')
        el.text = (v ? 'yes' : 'no')
      end
    end
  end

  # An individual entry in a feed. As an Atom::Element, it can be
  # manipulated using accessors for each of its child elements. You
  # should be able to set them using an instance of any class that
  # makes sense
  #
  # Entries have the following children:
  #
  # id:: a universally unique IRI which permanently identifies the entry
  # title:: a human-readable title (Atom::Text)
  # content:: contains or links to the content of an entry (Atom::Content)
  # rights:: information about rights held in and over an entry (Atom::Text)
  # source:: the source feed's metadata (unimplemented)
  # published:: a Time "early in the life cycle of an entry"
  # updated:: the most recent Time an entry was modified in a way the publisher considers significant
  # summary:: a summary, abstract or excerpt of an entry (Atom::Text)
  #
  # There are also +categories+, +links+, +authors+ and +contributors+,
  # each of which is an Array of its respective type and can be used
  # thusly:
  #
  #   author = entry.authors.new :name => "Captain Kangaroo", :email => "kanga@example.net"
  #
  class Entry < Atom::Element
    is_atom_element :entry

    # the master list of standard children and the types they map to
    atom_string :id

    atom_element :title, Atom::Title
    atom_element :summary, Atom::Summary
    atom_element :content, Atom::Content

    atom_element :rights, Atom::Rights

    atom_element :source, Atom::Source

    atom_time :published
    atom_time :updated
    time ['app', PP_NS], :edited

    atom_elements :author, :authors, Atom::Author
    atom_elements :contributor, :contributors, Atom::Contributor

    element ['app', PP_NS], :control, Atom::Control

    include HasCategories
    include HasLinks

    atom_link :edit_url, :rel => 'edit'

    def inspect # :nodoc:
      "#<Atom::Entry id:'#{self.id}'>"
    end

    def draft
      control and control.draft
    end

    alias :draft? :draft

    def draft!
      self.draft = true
    end

    def draft= is_draft
      unless control
        instance_variable_set '@control', Atom::Control.new
      end
      control.draft = is_draft
    end
  end
end
