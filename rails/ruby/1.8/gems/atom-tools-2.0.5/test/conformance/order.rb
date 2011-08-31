require "test/unit"
require "atom/feed"

# http://www.intertwingly.net/wiki/pie/OrderConformanceTests

FEED = Atom::Feed.new("http://www.snellspace.com/public/ordertest.xml")
FEED.update!

class TestOrderConformance < Test::Unit::TestCase
  def test_0
    entry = FEED.entries[0]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/1", entry.id
    assert_equal "Simple order, nothing fancy", entry.title.to_s
    assert_equal "Simple ordering, nothing fancy", entry.summary.to_s
    assert_equal Time.parse("2006-01-26T09:20:01Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  def test_1
    entry = FEED.entries[1]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/2", entry.id
    assert_equal "Same as the first, only mixed up a bit", entry.title.to_s
    assert_equal "Same as the first, only mixed up a bit", entry.summary.to_s
    assert_equal Time.parse("2006-01-26T09:20:02Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  # Multiple alt link elements, which does your reader show?
  def test_2
    entry = FEED.entries[2]

    # both links should be available, but it's up to you to choose which one to use 

    assert_link_href(entry, "http://www.snellspace.com/public/alternate") { |l| l["rel"] == "alternate" and l["type"] == nil }

    assert_link_href(entry, "http://www.snellspace.com/public/alternate2") { |l| l["rel"] == "alternate" and l["type"] == "text/plain" }
  end

  # Multiple link elements, does your feed reader show the "alternate" correctly? (also checks to see if the reader is paying attention to link rel values)
  def test_3
    entry = FEED.entries[3]

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")

    assert_link_href(entry, "http://www.snellspace.com/public/related") { |l| l["rel"] == "related" }

    assert_link_href(entry, "http://www.snellspace.com/public/foo") { |l| l["rel"] == "urn:foo" }
  end

  # Entry with a source first.. does your feed reader show the right title, updated, and alt link?
  def test_4
    entry = FEED.entries[4]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/5", entry.id
    assert_equal "Entry with a source first", entry.title.to_s
    assert_equal Time.parse("2006-01-26T09:20:05Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  # Entry with a source first.. does your feed reader show the right title, updated, and alt link?
  #  ^-- quoted summary is a typo, source is last
  def test_5
    entry = FEED.entries[5]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/6", entry.id
    assert_equal "Entry with a source last", entry.title.to_s
    assert_equal Time.parse("2006-01-26T09:20:06Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  # Entry with a source in the middle.. does your feed reader show the right id, title, updated, and alt link?
  def test_6
    entry = FEED.entries[6]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/7", entry.id
    assert_equal "Entry with a source in the middle", entry.title.to_s
    assert_equal Time.parse("2006-01-26T09:20:07Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  # Atom elements in an extension element
  def test_7
    entry = FEED.entries[7]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/8", entry.id
    assert_equal "Atom elements in an extension element", entry.title.to_s
    assert_equal Time.parse("2006-01-26T09:20:08Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  # Atom elements in an extension element
  def test_8
    entry = FEED.entries[8]

    assert_equal "tag:example.org,2006:atom/conformance/element_order/9", entry.id
    assert_equal "Atom elements in an extension element", entry.title.to_s
    assert_equal Time.parse("2006-01-26T09:20:09Z"), entry.updated

    assert_alternate_href(entry, "http://www.snellspace.com/public/alternate")
  end

  def assert_link_href(entry, href, &block)
    link = entry.links.find(&block)
    assert_equal href, link["href"]
  end

  def assert_alternate_href(entry, href)
    assert_link_href(entry, href) { |l| l["rel"] == "alternate" }
  end
end
