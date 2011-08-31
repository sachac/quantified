#!/usr/bin/ruby

require "test/unit"

require "atom/feed"

class AtomTest < Test::Unit::TestCase
  def test_feed_duplicate_id
    feed = Atom::Feed.new

    entry1 = get_entry
    entry1.id = "http://example.org/test"
    entry1.content = "an original entry"
    entry1.updated!

    feed << entry1

    assert_equal(1, feed.entries.length)
    assert_equal("an original entry", feed.entries.first.content.to_s)

    feed << entry1.dup

    assert_equal(1, feed.entries.length)
    assert_equal("an original entry", feed.entries.first.content.to_s)

    entry2 = entry1.dup
    entry2.content = "a changed entry"
    entry2.updated!

    feed << entry2

    assert_equal(1, feed.entries.length)
    assert_equal("a changed entry", feed.entries.last.content.to_s)
  end

  def test_tags
    entry = get_entry
    entry.tag_with "test tags"

    xml = get_elements entry

    assert_has_category(xml, "test")
    assert_has_category(xml, "tags")
  end

  def assert_has_category xml, term
    assert_not_nil(REXML::XPath.match(xml, "/entry/category[@term = #{term}]"))
  end

  def assert_has_content_type xml, type
    assert_equal(type, xml.elements["/entry/content"].attributes["type"])
  end

  def get_entry
    Atom::Entry.new
  end

  def get_elements entry
    xml = entry.to_xml

    assert_equal(entry.to_s, Atom::Entry.parse(xml).to_s)

    base_check xml

    xml
  end

  def base_check xml
    assert_equal("entry", xml.root.name)
    assert_equal("http://www.w3.org/2005/Atom", xml.root.namespace)
  end
end
