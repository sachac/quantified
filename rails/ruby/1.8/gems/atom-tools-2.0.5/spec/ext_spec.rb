require File.dirname(__FILE__) + '/spec_helper'

require 'atom/entry'

module Atom
  THR_NS  = "http://purl.org/syndication/thread/1.0"
  SLUG_NS = 'http://example.org/ns/slug'

  class InReplyTo < Atom::Element
    is_element THR_NS, :"in-reply-to"

    atom_attrb :ref
    atom_attrb :href
    atom_attrb :type
    atom_attrb :source
  end

  class Entry
    attrb   ['sl', SLUG_NS], 'slug'
    element ['thr', THR_NS], :"in-reply-to", InReplyTo
  end
end

describe Atom::Entry do
  it 'should correctly write extension attributes' do
    entry = Atom::Entry.new
    entry.slug = 'hallo'

    entry.to_s.should =~ /sl:slug/
    entry.to_s.should =~ /xmlns:sl='#{Atom::SLUG_NS}'/
  end

  describe 'in-reply-to' do
    it 'should be written with the correct namespace' do
      entry = Atom::Entry.new
      entry.in_reply_to = { :ref => 'http://example.org/some-entry' }

      entry.to_s.should =~ /ref='http:\/\/example.org/
      entry.to_s.should =~ Regexp.new(Atom::THR_NS)
    end
  end
end
