require "test/unit"
require "atom/feed"

# wiki page at <http://www.intertwingly.net/wiki/pie/TitleConformanceTests>

# http://atomtests.philringnalda.com/tests/item/title/html-cdata.atom
# http://atomtests.philringnalda.com/tests/item/title/html-entity.atom
# http://atomtests.philringnalda.com/tests/item/title/html-ncr.atom
# http://atomtests.philringnalda.com/tests/item/title/text-cdata.atom
# http://atomtests.philringnalda.com/tests/item/title/text-entity.atom
# http://atomtests.philringnalda.com/tests/item/title/text-ncr.atom
# http://atomtests.philringnalda.com/tests/item/title/xhtml-entity.atom
# http://atomtests.philringnalda.com/tests/item/title/xhtml-ncr.atom

# I make no attempt to normalize the XML from entry.title.to_s
# therefore, the direct equalities I do below are unwise.
# (eg. they *could* return &lt; or &#60; and still be perfectly correct)
#
# It shouldn't be a problem unless REXML changes what it encodes.
class TestTitleConformance < Test::Unit::TestCase
  def test_html_cdata
    url = "http://atomtests.philringnalda.com/tests/item/title/html-cdata.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "html", entry.title["type"]
    assert_equal "&lt;title>", entry.title.html
  end

  def test_html_entity
    url = "http://atomtests.philringnalda.com/tests/item/title/html-entity.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "html", entry.title["type"]
    assert_equal "&lt;title>", entry.title.html
  end

  def test_html_ncr
    url = "http://atomtests.philringnalda.com/tests/item/title/html-ncr.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "html", entry.title["type"]
    assert_equal "&lt;title>", entry.title.html
  end

  def test_text_cdata
    url = "http://atomtests.philringnalda.com/tests/item/title/text-cdata.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "text", entry.title["type"]
    assert_equal "&lt;title&gt;", entry.title.html
  end

  def test_text_entity
    url = "http://atomtests.philringnalda.com/tests/item/title/text-entity.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "text", entry.title["type"]
    assert_equal "&lt;title&gt;", entry.title.html
  end

  def test_text_ncr
    url = "http://atomtests.philringnalda.com/tests/item/title/text-ncr.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "text", entry.title["type"]
    assert_equal "&lt;title&gt;", entry.title.html
  end

  def test_xhtml_entity
    url = "http://atomtests.philringnalda.com/tests/item/title/xhtml-entity.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "xhtml", entry.title["type"]
    assert_equal "&lt;title>", entry.title.html
  end

  def test_xhtml_ncr
    url = "http://atomtests.philringnalda.com/tests/item/title/xhtml-ncr.atom"

    feed = Atom::Feed.new(url)
    feed.update!

    entry = feed.entries.first
    assert_equal "xhtml", entry.title["type"]
    assert_equal "&#60;title>", entry.title.html
  end
end
