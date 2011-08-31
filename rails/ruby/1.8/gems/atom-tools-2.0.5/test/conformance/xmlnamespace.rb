require "test/unit"
require "atom/feed"

class TestXMLNamespaceConformance < Test::Unit::TestCase
  def test_baseline
    feed = Atom::Feed.new "http://plasmasturm.org/attic/atom-tests/nondefaultnamespace-baseline.atom"
    feed.update!

    assert_baseline feed
  end

  def assert_baseline feed
    assert_equal Time.parse("2006-01-18T12:26:54+01:00"), feed.updated
    assert_equal "http://example.org/tests/namespace/result.html", feed.links.first["href"]

    assert_equal "urn:uuid:f8195e66-863f-11da-9fcb-dd680b0526e0", feed.id

    assert_equal "Aristotle Pagaltzis", feed.authors.first.name
    assert_equal "pagaltzis@gmx.de", feed.authors.first.email

    entry = feed.entries.first

    assert_equal "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a", entry.id

    assert_equal Time.parse("2006-01-18T12:26:54+01:00"), entry.updated
    assert_equal "http://example.org/tests/namespace/result.html", entry.links.first["href"]

    # XXX content.html should strip namespace prefixes
    e = entry.content.xml
    
    assert_equal "http://www.w3.org/1999/xhtml", e[1].namespace
    assert_equal "p", e[1].name
    assert_equal "For information, see:", e[1].text
  end

  def test_1
    feed = Atom::Feed.new "http://plasmasturm.org/attic/atom-tests/nondefaultnamespace.atom"
    feed.update!

    assert_baseline feed
  end

  def test_2
    feed = Atom::Feed.new "http://plasmasturm.org/attic/atom-tests/nondefaultnamespace-xhtml.atom"
    feed.update!

    assert_baseline feed
  end

  def test_3
    assert(false, "I haven't written the last test")
    # XXX FINISHME
  end
end
