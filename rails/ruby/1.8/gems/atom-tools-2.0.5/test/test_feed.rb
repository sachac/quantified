require "test/unit"

require "atom/feed"
require "webrick"

class AtomFeedTest < Test::Unit::TestCase
  def setup
    @http = Atom::HTTP.new
    @port = rand(1024) + 1024
    @s = WEBrick::HTTPServer.new :Port => @port, 
               :Logger => WEBrick::Log.new($stderr, WEBrick::Log::FATAL), 
               :AccessLog => []

    @test_feed =<<END
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Example Feed</title>
  <link href="http://example.org/"/>
  <updated>2003-12-13T18:30:02Z</updated>
  <author>
    <name>John Doe</name>
  </author>
  <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>

  <entry>
    <title>Atom-Powered Robots Run Amok</title>
    <link href="http://example.org/2003/12/13/atom03"/>
    <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
    <updated>2003-12-13T18:30:02Z</updated>
    <summary>Some text.</summary>
  </entry>
</feed>
END
  end

  def test_merge
    feed1 = Atom::Feed.new
   
    feed1.title = "title"

    feed1.subtitle = "<br>"
    feed1.subtitle["type"] = "html"

    a = feed1.authors.new
    a.name = "test"

    feed2 = Atom::Feed.new

    feed = feed1.merge(feed2)

    assert_equal "text", feed.title["type"]
    assert_equal "title", feed.title.to_s 

    assert_equal "html", feed.subtitle["type"]
    assert_equal "<br>", feed.subtitle.to_s

    assert_equal 1, feed.authors.length
    assert_equal "test", feed.authors.first.name
  end

  def test_update
    @s.mount_proc("/") do |req,res|
      assert_equal "application/atom+xml", req["Accept"]

      res.content_type = "application/atom+xml"
      res.body = @test_feed

      @s.stop
    end

    feed = Atom::Feed.new "http://localhost:#{@port}/"

    assert_equal nil, feed.title
    assert_equal nil, feed.id
    assert_equal [], feed.entries
    
    one_shot

    feed.update!

    assert_equal "Example Feed", feed.title.to_s
    assert_equal "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6", feed.id
    assert_equal 1, feed.entries.length
  end

  def test_media_types
    c = proc do |c_t|
      @s.mount_proc("/") do |req,res|
        res.content_type = c_t
        res.body = @test_feed

        @s.stop
      end
      # there's some kind of race condition here that will result in a
      # timeout sometimes. this is a dirty fix.
      sleep 0.5
      one_shot
    end
    
    feed = Atom::Feed.new "http://localhost:#{@port}/"

    # even if it looks like a feed, the server's word is law
    c.call("text/plain")
    assert_raise(Atom::WrongMimetype) { feed.update! }

    # a parameter shouldn't change the type
    c.call("application/atom+xml;type=feed")
    assert_nothing_raised { feed.update! }

    # type and subtype are case insensitive (param. attribute names too)
    c.call("ApPliCatIon/ATOM+XML")
    assert_nothing_raised { feed.update! }

    # text/xml isn't the preferred mimetype, but we'll accept it
    c.call("text/xml")
    assert_nothing_raised { feed.update! }

    # same goes for application/xml
    c.call("application/xml")
    assert_nothing_raised { feed.update! }

    # nil content type
    @s.mount_proc("/") do |req,res|
      res.body = @test_feed

      @s.stop
    end
    one_shot
    assert_raises(Atom::HTTPException) { feed.update! }
  end

  # prepares the server for a single request
  def one_shot; Thread.new { @s.start }; end
end
