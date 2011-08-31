require "test/unit"
require "atom/feed"

# wiki page at <http://www.intertwingly.net/wiki/pie/UpdatedConformanceTests>
# test feed at <http://intertwingly.net/testcase/updated.atom>

class TestUpdatedConformance < Test::Unit::TestCase
  def test_it_all
    feed = Atom::Feed.new "http://intertwingly.net/testcase/updated.atom"

    assert_equal [], feed.entries

    # initial filling
    feed.update!
    assert_equal "12 of 13 miner survive mine collapse", feed.entries.first.content.to_s.strip
  
    # this is an insignificant change, 
    # (ie. atom:updated_1 == atom:updated_2),
    #
    # the update is applied, your application can handle that however it wants.
    feed.update!
    assert_equal "12 of 13 miner<b>s</b> survive mine collapse", feed.entries.first.content.to_s.strip
   
    # now we've got a significant change 
    feed.update!
    assert_equal "12 of 13 miners <del>survive</del> <b>killed</b> in mine collapse", feed.entries.first.content.to_s.strip
 
    # and now the feed is gone totally
    assert_raises(Atom::FeedGone) do
      feed.update!
    end
  end
end
 
