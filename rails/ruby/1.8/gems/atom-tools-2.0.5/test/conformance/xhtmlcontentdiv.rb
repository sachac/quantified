require "test/unit"
require "atom/feed"

class TestXHTMLContentDivConformance < Test::Unit::TestCase
  def test_all
    feed = Atom::Feed.new("http://www.franklinmint.fm/2006/06/divtest.atom")
    feed.update!

    assert_equal "<b>test</b> content", feed.entries.first.content.html

    e = feed.entries.first.content.xml
    assert_equal "http://www.w3.org/1999/xhtml", e.first.namespace
    assert_equal "b", e.first.name
    assert_equal "test", e.first.text

    assert_equal " content", e.last.to_s
  end
end
