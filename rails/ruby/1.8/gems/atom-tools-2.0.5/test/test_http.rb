require "test/unit"

require "atom/http"
require "webrick"

class AtomHTTPTest < Test::Unit::TestCase
  REALM = "test authentication"
  USER = "test_user"
  PASS = "aoeuaoeu"

  # for Google AuthSub authentication
  TOKEN = "pq7266382__838"

  SECRET_DATA = "I kissed a boy once"

  def setup
    @http = Atom::HTTP.new
    @port = rand(1024) + 1024
    @s = WEBrick::HTTPServer.new :Port => @port, 
               :Logger => WEBrick::Log.new($stderr, WEBrick::Log::FATAL), 
               :AccessLog => []
  end

  def test_parse_wwwauth
    # a Basic WWW-Authenticate
    header = 'realm="SokEvo"'

    params = @http.send :parse_quoted_wwwauth, header
    assert_equal "SokEvo", params[:realm]

    # Digest is parsed a bit differently
    header = 'opaque="07UrfUiCYac5BbWJ", algorithm=MD5-sess, qop="auth", stale=TRUE, nonce="MDAx0Mzk", realm="test authentication"'

    params = @http.send :parse_wwwauth_digest, header

    assert_equal "test authentication", params[:realm]
    assert_equal "MDAx0Mzk", params[:nonce]
    assert_equal true, params[:stale]
    assert_equal "auth", params[:qop]
    assert_equal "MD5-sess", params[:algorithm]
    assert_equal "07UrfUiCYac5BbWJ", params[:opaque]
  end

  def test_GET
    mount_one_shot do |req,res|
      assert_equal("/", req.path)

      res.content_type = "text/plain"
      res.body = "Success!"
    end

    get_root
    
    assert_equal "200", @res.code 
    assert_equal "text/plain", @res.content_type 
    assert_equal "Success!", @res.body 
  end

  def test_GET_headers
    mount_one_shot do |req,res|
      assert_equal("tester agent", req["User-Agent"])
    end

    get_root("User-Agent" => "tester agent")

    assert_equal "200", @res.code 
  end

  def test_redirect
    @s.mount_proc("/") do |req,res|
      res.status = 302
      res["Location"] = "http://localhost:#{@port}/redirected"
      
      res.body = "ignore me."
    end

    @s.mount_proc("/redirected") do |req,res|
      res.content_type = "text/plain"
      res.body = "Success!"

      @s.stop
    end

    one_shot; get_root

    # the redirect should be transparent (to whatever extent it can be)
    assert_equal "200", @res.code
    assert_equal "Success!", @res.body
  end

  def test_redirect_loop
    @s.mount_proc("/") do |req,res|
      res.status = 302
      res["Location"] = "http://localhost:#{@port}/redirected"
    end

    @s.mount_proc("/redirected") do |req,res|
      res.status = 302
      res["Location"] = "http://localhost:#{@port}/"
    end

    one_shot
    
    assert_raises(Atom::HTTPException) { get_root }

    @s.stop
  end

  def test_redirect_non_GET_non_HEAD
    @s.mount_proc("/") do |req,res|
      assert_equal "POST", req.request_method
      res.status = 302
      res["Location"] = "http://localhost:#{@port}/redirected"
    end

    @s.mount_proc("/redirected") do |req,res|
      assert_equal "POST", req.request_method
      assert_equal "important message", req.body
      res.content_type = "text/plain"
      res.body = "Success!"
    end

    one_shot

    @res = @http.post "http://localhost:#{@port}/", "important message"

    assert_equal "302", @res.code

    @http.allow_all_redirects = true

    one_shot

    @res = @http.post "http://localhost:#{@port}/", "important message"

    assert_equal "200", @res.code
    assert_equal "Success!", @res.body

    @s.stop
  end

  def test_basic_auth
    mount_one_shot do |req,res|
      WEBrick::HTTPAuth.basic_auth(req, res, REALM) do |u,p|
        u == USER and p == PASS
      end

      res.body = SECRET_DATA
    end

    # no credentials
    assert_raises(Atom::Unauthorized) { get_root }

    # incorrect credentials
    @http.user = USER
    @http.pass = "incorrect_password"

    one_shot

    assert_raises(Atom::Unauthorized) { get_root }

    # no credentials, fancy block
    @http.when_auth do nil end

    one_shot

    assert_raises(Atom::Unauthorized) { get_root }

    # correct credentials, fancy block
    @http.when_auth do |abs_url,realm|
      assert_equal "http://localhost:#{@port}/", abs_url 
      assert_equal REALM, realm

      [USER, PASS]
    end

    one_shot

    assert_authenticates
  end

  def test_digest_auth
    # a dummy userdb (saves me creating a file)
    userdb = {}
    # with a single entry
    userdb[USER] = PASS

    # HTTPAuth::DigestAuth#authenticate uses this
    def userdb.get_passwd(realm, user, reload)
      Digest::MD5::hexdigest([user, realm, self[user]].join(":"))
    end
      
    authenticator = WEBrick::HTTPAuth::DigestAuth.new(
      :UserDB => userdb,
      :Realm => REALM,
      :Algorithm => "MD5"
    )

    @s.mount_proc("/") do |req,res|
      authenticator.authenticate(req, res)
      res.body = SECRET_DATA
    end
   
    one_shot

    # no credentials
    assert_raises(Atom::Unauthorized) { get_root }

    @http.user = USER
    @http.pass = PASS

    # correct credentials
    assert_authenticates

    @s.stop
  end

  def test_wsse_auth
    mount_one_shot do |req,res|
      assert_equal 'WSSE profile="UsernameToken"', req["Authorization"]

      xwsse = req["X-WSSE"]

      p = @http.send :parse_quoted_wwwauth, xwsse

      assert_equal USER, p[:Username]
      assert_match /^UsernameToken /, xwsse

      # Base64( SHA1( Nonce + CreationTimestamp + Password ) )
      pd_string = p[:Nonce].unpack("m").first + p[:Created] + PASS
      password_digest = [Digest::SHA1.digest(pd_string)].pack("m").chomp

      assert_equal password_digest, p[:PasswordDigest]

      res.body = SECRET_DATA
    end

    @http.always_auth = :wsse
    @http.user = USER
    @http.pass = PASS

    assert_authenticates
  end

  def test_authsub_auth
    mount_one_shot do |req,res|
      assert_equal %{AuthSub token="#{TOKEN}"}, req["Authorization"]

      res.body = SECRET_DATA
    end

    @http.always_auth = :authsub
    @http.token = TOKEN

    assert_authenticates
  end

  def test_multiple_auth
    mount_one_shot do |req,res|
      # WEBrick doesn't seem to support sending multiple headers, so this is the best we can do
      res["WWW-Authenticate"] = %{NonexistantAuth parameter="yes", qop="auth", Basic realm="#{REALM}", something="true"}

      if req["Authorization"]
        res.body = SECRET_DATA
      else
        res.status = 401
      end
    end

    @http.user = USER
    @http.pass = PASS

    assert_authenticates
  end

  # mount a block on the test server, shutting the server down after a
  # single request
  def mount_one_shot &block
    @s.mount_proc("/") do |req,res|
      block.call req, res
      @s.stop
    end

    one_shot
  end

  # test that we authenticated properly
  def assert_authenticates
    get_root
    assert_equal "200", @res.code
    assert_equal SECRET_DATA, @res.body
  end

  # performs a GET on the test server
  def get_root(*args)
    @res = @http.get("http://localhost:#{@port}/", *args)
  end

  # sets up the server for a single request
  def one_shot; Thread.new { @s.start }; end
end
