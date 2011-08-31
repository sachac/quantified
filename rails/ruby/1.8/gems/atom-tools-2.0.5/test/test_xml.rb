$:.unshift 'lib/', File.dirname(__FILE__) + '/../lib'
require "test/unit"
require "atom/service"

class AtomTest < Test::Unit::TestCase
  def test_text_type_text
    entry = get_entry

    entry.title = "Let's talk about <html>"
    assert_equal("text", entry.title["type"])

    assert_match('&lt;', entry.title.xml.to_s)

    xml = entry.to_xml

    b = Atom::Entry.parse(xml).to_s

    base_check xml

    assert_equal("Let's talk about <html>", xml.elements["title"].text)

    assert_match('&lt;', entry.to_s)
  end

  def test_text_type_html
    entry = get_entry

    entry.title = "Atom-drunk pirates<br>run amok!"
    entry.title["type"] = "html"

    xml = get_elements entry

    assert_equal("Atom-drunk pirates<br>run amok!", xml.elements["title"].text)
    assert_equal("html", xml.elements["title"].attributes["type"])

    assert_match('&lt;', entry.to_s)
  end

  def test_text_type_xhtml
    entry = get_entry

    entry.title = "Atom-drunk pirates <em>run amok</em>!"
    entry.title["type"] = "xhtml"

    xml = get_elements entry

    assert_equal(XHTML::NS, xml.elements["title/div"].namespace)
    assert_equal("run amok", xml.elements["title/div/em"].text)

    assert_match('<em>', entry.to_s)
  end

  def test_html_text_with_entities
    entry = get_entry

    entry.title = "Atoms discovered to be smaller than 1&mu;m"
    entry.title["type"] = "html"

    assert_match(/&amp;mu;/, entry.to_s)
  end

  def test_author
    entry = get_entry
    a = entry.authors.new

    a.name= "Brendan Taylor"
    a.uri = "http://necronomicorp.com/blog/"

    xml = get_elements entry

    assert_equal("http://necronomicorp.com/blog/", xml.elements["author/uri"].text)
    assert_equal("Brendan Taylor", xml.elements["author/name"].text)
    assert_nil(xml.elements["author/email"])
  end

  def test_tags
    entry = get_entry
    entry.tag_with "test tags"

    xml = get_elements entry

    assert_has_category(xml, "test")
    assert_has_category(xml, "tags")
  end

  def test_updated
    entry = get_entry
    entry.updated = "1970-01-01"
    entry.content = "blah"

    assert entry.updated.is_a?(Time)

    xml = entry.to_xml

    b = Atom::Entry.parse(xml).to_s

    base_check xml

    assert_match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, xml.elements["updated"].text, "atom:updated isn't in xsd:datetime format")

    entry.updated!

    assert((Time.parse("1970-01-01") < entry.updated), "<updated/> is not updated")
  end

  def test_edited
    entry = get_entry

    assert_nil entry.edited

    entry.edited = "1990-04-07"
    assert entry.edited.is_a?(Time)

    xml = get_elements entry
    assert_equal(Atom::PP_NS, xml.elements["app:edited"].namespace)
    assert_match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, xml.elements["app:edited"].text,
      "atom:edited isn't in xsd:datetime format")

    entry.edited!
    assert((Time.parse("1990-04-07") < entry.edited), "<edited/> is not updated")
  end

  def test_out_of_line
    entry = get_entry

    entry.content = "this shouldn't appear"
    entry.content["src"] = 'http://example.org/test.png'
    entry.content["type"] = "image/png"

    xml = get_elements(entry)

    assert_nil xml.elements["content"].text
    assert_equal("http://example.org/test.png", xml.elements["content"].attributes["src"])
    assert_equal("image/png", xml.elements["content"].attributes["type"])
  end

  def test_extensions
    entry = get_entry

    assert(entry.extensions.empty?)

    element = REXML::Element.new("test")
    element.add_namespace "http://purl.org/"

    entry.extensions << element

    assert entry.extensions.member?(element)

    xml = get_elements entry

    assert_equal(REXML::Element, xml.elements["test"].class)
    assert_equal("http://purl.org/", xml.elements["test"].namespace)
  end

  def test_roundtrip_extension
    entry = Atom::Entry.parse("<entry xmlns='http://www.w3.org/2005/Atom' xmlns:nil='http://necronomicorp.com/nil'><nil:ext/></entry>")

    assert_match(/xmlns:nil='http:\/\/necronomicorp.com\/nil'/, entry.to_s)
  end

  def test_app_control
    entry = get_entry

    assert !entry.draft

    assert_nil get_elements(entry).elements["control"]

    entry.draft = true

    xml = get_elements entry

    assert_equal Atom::PP_NS, xml.elements["app:control"].namespace
    assert_equal Atom::PP_NS, xml.elements["app:control/app:draft"].namespace
    assert_equal "yes", xml.elements["app:control/app:draft"].text

    entry2 = Atom::Entry.parse xml

    assert entry.draft
  end

  def test_extensive_entry_parsing
str = '<entry xmlns="http://www.w3.org/2005/Atom">
  <title>Atom draft-07 snapshot</title>
  <link rel="alternate" type="text/html"
    href="http://example.org/2005/04/02/atom"/>
  <link rel="enclosure" type="audio/mpeg" length="1337"
    href="http://example.org/audio/ph34r_my_podcast.mp3"/>
  <id>tag:example.org,2003:3.2397</id>
  <updated>2005-07-31T12:29:29Z</updated>
  <published>2003-12-13T08:29:29-04:00</published>
  <author>
    <name>Mark Pilgrim</name>
    <uri>http://example.org/</uri>
    <email>f8dy@example.com</email>
  </author>
  <contributor>
    <name>Sam Ruby</name>
  </contributor>
  <contributor>
    <name>Joe Gregorio</name>
  </contributor>
  <content type="xhtml" xml:lang="en"
    xml:base="http://diveintomark.org/">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <p><i>[Update: The Atom draft is finished.]</i></p>
    </div>
  </content>
</entry>'

    entry = Atom::Entry.parse(str)

    assert_equal("Atom draft-07 snapshot", entry.title.to_s)
    assert_equal("tag:example.org,2003:3.2397", entry.id)

    assert_equal(Time.parse("2005-07-31T12:29:29Z"), entry.updated)
    assert_equal(Time.parse("2003-12-13T08:29:29-04:00"), entry.published)

    assert_equal(2, entry.links.length)
    assert_equal("alternate", entry.links.first["rel"])
    assert_equal("text/html", entry.links.first["type"])
    assert_equal("http://example.org/2005/04/02/atom", entry.links.first["href"])

    assert_equal("enclosure", entry.links.last["rel"])
    assert_equal("audio/mpeg", entry.links.last["type"])
    assert_equal("1337", entry.links.last["length"])
    assert_equal("http://example.org/audio/ph34r_my_podcast.mp3", entry.links.last["href"])

    assert_equal(1, entry.authors.length)
    assert_equal("Mark Pilgrim", entry.authors.first.name)
    assert_equal("http://example.org/", entry.authors.first.uri)
    assert_equal("f8dy@example.com", entry.authors.first.email)

    assert_equal(2, entry.contributors.length)
    assert_equal("Sam Ruby", entry.contributors.first.name)
    assert_equal("Joe Gregorio", entry.contributors.last.name)

    assert_equal("xhtml", entry.content["type"])

    assert_match("<p><i>[Update: The Atom draft is finished.]</i></p>", 
                 entry.content.to_s)

    assert_equal("http://diveintomark.org/", entry.content.base)
    # XXX unimplemented
#    assert_equal("en", entry.content.lang)
  end

  def test_extensive_feed_parsing
feed = <<END
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title type="text">dive into mark</title>
  <subtitle type="html">
    A &lt;em&gt;lot&lt;/em&gt; of effort
    went into making this effortless
  </subtitle>
  <updated>2005-07-31T12:29:29Z</updated>
  <id>tag:example.org,2003:3</id>
  <link rel="alternate" type="text/html"
   hreflang="en" href="http://example.org/"/>
  <link rel="self" type="application/atom+xml"
   href="http://example.org/feed.atom"/>
  <rights>Copyright (c) 2003, Mark Pilgrim</rights>
  <generator uri="http://www.example.com/" version="1.0">
    Example Toolkit
  </generator>
  <entry>
    <title>Atom draft-07 snapshot</title>
    <author>
      <name>Mark Pilgrim</name>
      <uri>http://example.org/</uri>
      <email>f8dy@example.com</email>
    </author>
    <link rel="alternate" type="text/html"
     href="http://example.org/2005/04/02/atom"/>
    <id>tag:example.org,2003:3.2397</id>
    <updated>2005-07-31T12:29:29Z</updated>
  </entry>
</feed>
END

    feed = Atom::Feed.parse(feed)

    assert_equal("", feed.base)

    assert_equal("text", feed.title["type"])
    assert_equal("dive into mark", feed.title.to_s)

    assert_equal("html", feed.subtitle["type"])
    assert_equal("\n    A <em>lot</em> of effort\n    went into making this effortless\n  ", feed.subtitle.to_s)

    assert_equal(Time.parse("2005-07-31T12:29:29Z"), feed.updated)
    assert_equal("tag:example.org,2003:3", feed.id)

    assert_equal([], feed.authors)

    alt = feed.links.find { |l| l["rel"] == "alternate" }
    assert_equal("alternate", alt["rel"])
    assert_equal("text/html", alt["type"])
    assert_equal("en", alt["hreflang"])
    assert_equal("http://example.org/", alt["href"])

    assert_equal("text", feed.rights["type"])
    assert_equal("Copyright (c) 2003, Mark Pilgrim", feed.rights.to_s)

    assert_equal("\n    Example Toolkit\n  ", feed.generator)
    # XXX unimplemented
    # assert_equal("http://www.example.com/", feed.generator["uri"])
    # assert_equal("1.0", feed.generator["version"])

    assert_equal(1, feed.entries.length)
    assert_equal "Atom draft-07 snapshot", feed.entries.first.title.to_s
  end

  def test_parse_html_content
    xml = <<END
<entry xmlns="http://www.w3.org/2005/Atom">
  <summary type="html">
    &lt;p>...&amp;amp; as a result of this, I submit that &lt;var>pi&lt;/var> &amp;lt; 4
  </summary>
</entry>
END

    entry = Atom::Entry.parse(xml)

    assert_equal "html", entry.summary["type"]
    assert_equal "<p>...&amp; as a result of this, I submit that <var>pi</var> &lt; 4", entry.summary.html.strip
  end

  def test_parse_goofy_entries
xml = <<END
<entry xmlns="http://www.w3.org/2005/Atom">
<content type="html"></content>
</entry>
END

    entry = Atom::Entry.parse(xml)

    assert_equal("", entry.content.to_s)
  end

  def test_parse_outofline_content
    xml = <<END
<entry xmlns="http://www.w3.org/2005/Atom">
  <content src="http://necronomicorp.com/nil">
src means empty content.
  </content>
</entry>
END

    entry = Atom::Entry.parse xml

    assert_equal "http://necronomicorp.com/nil", entry.content["src"]
    assert_equal "", entry.content.to_s
  end

  def test_serialize_base
    entry = Atom::Entry.new

    entry.base = "http://necronomicorp.com/nil"

    base = get_elements(entry).root.attributes["xml:base"]
    assert_equal "http://necronomicorp.com/nil", base

    entry.base = URI.parse("http://necronomicorp.com/nil")

    base = get_elements(entry).root.attributes["xml:base"]
    assert_equal "http://necronomicorp.com/nil", base
  end

  def test_relative_base
    base_url = "http://www.tbray.org/ongoing/ongoing.atom"
    doc = "<entry xmlns='http://www.w3.org/2005/Atom' xml:base='When/200x/2006/10/11/'/>"

    entry = Atom::Entry.parse(doc, base_url)
    assert_equal("http://www.tbray.org/ongoing/When/200x/2006/10/11/", entry.base)
  end

  def test_relative_src
    base_url = "http://example.org/foo/"
    doc = "<entry xmlns='http://www.w3.org/2005/Atom'><content src='./bar'/></entry>"

    entry = Atom::Entry.parse(doc, base_url)
    assert_equal("http://example.org/foo/bar", entry.content['src'])
  end

  def test_edit_url
    doc = <<END
<entry xmlns="http://www.w3.org/2005/Atom"><link rel="edit"/></entry>
END
    entry = Atom::Entry.parse(doc)

    assert_nil(entry.edit_url)

    doc = <<END
<entry xmlns="http://www.w3.org/2005/Atom"><link rel="edit"/></entry>
END

    entry = Atom::Entry.parse(doc)

    assert_nil(entry.edit_url)

    doc = <<END
<entry xmlns="http://www.w3.org/2005/Atom">
  <link rel="edit" href="http://necronomicorp.com/nil"/>
</entry>
END

    entry = Atom::Entry.parse(doc)

    assert_equal("http://necronomicorp.com/nil", entry.edit_url)

    entry.edit_url = "http://necronomicorp.com/foo"
    assert_equal "http://necronomicorp.com/foo", entry.edit_url
  end

  def assert_has_category xml, term
    assert_not_nil(REXML::XPath.match(xml, "/entry/category[@term = #{term}]"))
  end

  def assert_has_content_type xml, type
    assert_equal(type, xml.elements["content"].attributes["type"])
  end

  def get_entry
    Atom::Entry.new
  end

  # round-trips it to make sure things stay the same
  def get_elements entry
    xml = entry.to_xml

    b = Atom::Entry.parse(xml)

    assert_equal(xml.to_s, b.to_s)

    base_check xml

    xml
  end

  def base_check xml
    assert_equal("entry", xml.root.name)
    assert_equal("http://www.w3.org/2005/Atom", xml.root.namespace)
  end
end
