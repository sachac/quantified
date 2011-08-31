require "test/unit"

require "atom/service"

# needed for hpricot
require "rubygems"

class FakeHTTP
  Response = Struct.new(:body, :code, :content_type)

  def initialize table
    @table = table
  end

  def get url, headers = {}
    res = Response.new

    data = @table[url.to_s]

    res.body = data[1]
    res.code = 200.to_s
    res.content_type = data[0]

    def res.validate_content_type valid; valid.member? content_type; end

    res
  end
end

class AtomProtocolTest < Test::Unit::TestCase
  attr_reader :have_hpricot

  def initialize *args
    super

    require "hpricot"
    @have_hpricot = true
  rescue LoadError
    puts "skipping hpricot tests"
  end

  def test_introspection
    doc = <<END
<service xmlns="http://www.w3.org/2007/app"
  xmlns:atom="http://www.w3.org/2005/Atom">
  <workspace>
    <atom:title>My Blog</atom:title>
    <collection href="http://example.org/myblog/entries">
      <atom:title>Entries</atom:title>
    </collection>
    <collection href="http://example.org/myblog/fotes">
      <atom:title>Photos</atom:title>
      <accept>image/*</accept>
    </collection>
  </workspace>
</service>
END

    service = Atom::Service.parse doc

    ws = service.workspaces.first
    assert_equal "My Blog", ws.title.to_s

    coll = ws.collections.first
    assert_equal "http://example.org/myblog/entries", coll.href
    assert_equal "Entries", coll.title.to_s
    assert_equal ["application/atom+xml;type=entry"], coll.accepts

    coll = ws.collections.last
    assert_equal "http://example.org/myblog/fotes", coll.href
    assert_equal "Photos", coll.title.to_s
    assert_equal ["image/*"], coll.accepts

    http = service.instance_variable_get(:@http)
    assert_instance_of Atom::HTTP, http
  end

  def test_write_introspection
    service = Atom::Service.new

    ws = service.workspaces.new

    ws.title = "Workspace 1"

    coll = Atom::Collection.new "http://example.org/entries"
    coll.title = "Entries"
    ws.collections << coll

    coll = Atom::Collection.new "http://example.org/audio"
    coll.title = "Audio"
    coll.accepts = ["audio/*"]
    ws.collections << coll

    nses = { "app" => Atom::PP_NS, "atom" => Atom::NS }

    doc = REXML::Document.new(service.to_s)

    assert_equal "http://www.w3.org/2007/app", doc.root.namespace

    ws = REXML::XPath.first( doc.root,
                              "/app:service/app:workspace",
                              nses )

    title = REXML::XPath.first( ws, "./atom:title", nses)

    assert_equal "Workspace 1", title.text
    assert_equal "http://www.w3.org/2005/Atom", title.namespace

    colls = REXML::XPath.match( ws, "./app:collection", nses)
    assert_equal(2, colls.length)

    entries = colls.first

    assert_equal "http://example.org/entries", entries.attributes["href"]

    title = REXML::XPath.first(entries, "./atom:title", nses)
    assert_equal "Entries", title.text

    accepts = REXML::XPath.first(entries, "./app:accept", nses)
    assert_nil accepts

    audio = colls.last

    assert_equal "http://example.org/audio", audio.attributes["href"]

    title = REXML::XPath.first(audio, "./atom:title", nses)
    assert_equal "Audio", title.text

    accepts = REXML::XPath.first(audio, "./app:accept", nses)
    assert_equal "audio/*", accepts.text
  end

  def test_dont_specify_http_object
    collection = Atom::Collection.new("http://necronomicorp.com/testatom?atom")

    assert_instance_of Atom::HTTP, collection.instance_variable_get("@http")
  end

  def test_autodiscover_service_link
    return unless have_hpricot

    http = FakeHTTP.new \
      'http://example.org/' => [ 'text/html', '<html><link rel="service" href="svc">' ],
      'http://example.org/xhtml' => [ 'text/html', '<html><head><link rel="service" href="svc"/></head></html>' ],
      'http://example.org/svc' => [ 'application/atomsvc+xml', '<service xmlns="http://www.w3.org/2007/app"/>' ]

    svc = Atom::Service.discover 'http://example.org/', http
    assert_instance_of Atom::Service, svc

    svc = Atom::Service.discover 'http://example.org/xhtml', http
    assert_instance_of Atom::Service, svc
  end

  def test_autodiscover_rsd
    return unless have_hpricot

    http = FakeHTTP.new \
      'http://example.org/' => [ 'text/html', '<html><link rel="EditURI" href="rsd">' ],
      'http://example.org/svc' => [ 'application/atomsvc+xml', '<service xmlns="http://www.w3.org/2007/app"/>' ],
      'http://example.org/rsd' => [ 'text/xml', '<rsd version="1.0" xmlns="http://archipelago.phrasewise.com/rsd"><service><apis><api name="Atom" apiLink="svc" /></apis></service></rsd>' ]

    svc = Atom::Service.discover 'http://example.org/', http
    assert_instance_of Atom::Service, svc
  end

  def test_autodiscover_conneg
    http = FakeHTTP.new \
      'http://example.org/svc' => [ 'application/atomsvc+xml', '<service xmlns="http://www.w3.org/2007/app"/>' ]

    svc = Atom::Service.discover 'http://example.org/svc', http
    assert_instance_of Atom::Service, svc
  end

  def test_cant_autodiscover
    return unless have_hpricot

    http = FakeHTTP.new 'http://example.org/h' => [ 'text/html', '<html>' ],
                       'http://example.org/t' => [ 'text/plain', 'no joy.' ]

    assert_raises Atom::AutodiscoveryFailure do
      Atom::Service.discover 'http://example.org/h', http
    end

    assert_raises Atom::AutodiscoveryFailure do
      Atom::Service.discover 'http://example.org/t', http
    end
  end
end
