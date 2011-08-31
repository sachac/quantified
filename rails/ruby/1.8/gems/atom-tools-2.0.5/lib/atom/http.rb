require "net/http"
require "net/https"
require "uri"
require "cgi"

require "atom/cache"

require "digest/sha1"
require "digest/md5"

module URI # :nodoc: all
  class Generic; def to_uri; self; end; end
end

class String # :nodoc:
  def to_uri; URI.parse(self); end
end

module Atom
  TOOLS_VERSION = '2.0.5'
  UA = "atom-tools " + TOOLS_VERSION

  module DigestAuth
    CNONCE = Digest::MD5.hexdigest("%x" % (Time.now.to_i + rand(65535)))

    @@nonce_count = -1

    # quoted-strings plus a few special cases for Digest
    def parse_wwwauth_digest param_string
      params = parse_quoted_wwwauth param_string
      qop = params[:qop] ? params[:qop].split(",") : nil

      param_string.gsub(/stale=([^,]*)/) do
        params[:stale] = ($1.downcase == "true")
      end

      params[:algorithm] = "MD5"
      param_string.gsub(/algorithm=([^,]*)/) { params[:algorithm] = $1 }

      params
    end

    def h(data); Digest::MD5.hexdigest(data); end
    def kd(secret, data); h(secret + ":" + data); end

    # HTTP Digest authentication (RFC 2617)
    def digest_authenticate(req, url, param_string = "")
      raise "Digest authentication requires a WWW-Authenticate header" if param_string.empty?

      params = parse_wwwauth_digest(param_string)
      qop = params[:qop]

      user, pass = username_and_password_for_realm(url, params[:realm])

      if params[:algorithm] == "MD5"
        a1 = user + ":" + params[:realm] + ":" + pass
      else
        # XXX MD5-sess
        raise "I only support MD5 digest authentication (not #{params[:algorithm].inspect})"
      end

      if qop.nil? or qop.member? "auth"
        a2 = req.method + ":" + req.path
      else
        # XXX auth-int
        raise "only 'auth' qop supported (none of: #{qop.inspect})"
      end

      if qop.nil?
        response = kd(h(a1), params[:nonce] + ":" + h(a2))
      else
        @@nonce_count += 1
        nc = ('%08x' % @@nonce_count)

        # XXX auth-int
        data = "#{params[:nonce]}:#{nc}:#{CNONCE}:#{"auth"}:#{h(a2)}"

        response = kd(h(a1), data)
      end

      header = %Q<Digest username="#{user}", uri="#{req.path}", realm="#{params[:realm]}", response="#{response}", nonce="#{params[:nonce]}">

      if params[:opaque]
        header += %Q<, opaque="#{params[:opaque]}">
      end

      if params[:algorithm] != "MD5"
        header += ", algorithm=#{algo}"
      end

      if qop
        # XXX auth-int
        header += %Q<, nc=#{nc}, cnonce="#{CNONCE}", qop=auth>
      end

      req["Authorization"] = header
    end
  end

  class HTTPException < RuntimeError # :nodoc:
  end
  class Unauthorized < Atom::HTTPException  # :nodoc:
  end
  class WrongMimetype < Atom::HTTPException # :nodoc:
  end

  # An object which handles the details of HTTP - particularly
  # authentication and caching (neither of which are fully implemented).
  #
  # This object can be used on its own, or passed to an Atom::Service,
  # Atom::Collection or Atom::Feed, where it will be used for requests.
  #
  # All its HTTP methods return a Net::HTTPResponse
  class HTTP
    include DigestAuth

    # used by the default #when_auth
    attr_accessor :user, :pass

    # the token used for Google's AuthSub authentication
    attr_accessor :token

    # when set to :basic, :wsse or :authsub, this will send an
    # Authentication header with every request instead of waiting for a
    # challenge from the server.
    #
    # be careful; always_auth :basic will send your username and
    # password in plain text to every URL this object requests.
    #
    # :digest won't work, since Digest authentication requires an
    # initial challenge to generate a response
    #
    # defaults to nil
    attr_accessor :always_auth
    # if this is true, we tell Net::HTTP to die if it can't verify the SSL when doing https
    attr_accessor :strict_ssl

    # automatically handle redirects, even for POST/PUT/DELETE requests?
    #
    # defaults to false, which will transparently redirect GET requests
    # but return a Net::HTTPRedirection object when the server
    # indicates to redirect a POST/PUT/DELETE
    attr_accessor :allow_all_redirects

    # if set, 'cache' should be a directory for a disk cache, or an object
    # with the same interface as Atom::FileCache
    def initialize cache = nil
      if cache.is_a? String
        @cache = FileCache.new(cache)
      elsif cache
        @cache = cache
      else
        @cache = NilCache.new
      end

      # initialize default #when_auth
      @get_auth_details = lambda do |abs_url, realm|
        if @user and @pass
          [@user, @pass]
        else
          nil
        end
      end
    end

    # GETs an url
    def get url, headers = {}
      http_request(url, Net::HTTP::Get, nil, headers)
    end

    # POSTs body to an url
    def post url, body, headers = {}
      http_request(url, Net::HTTP::Post, body, headers)
    end

    # PUTs body to an url
    def put url, body, headers = {}
      http_request(url, Net::HTTP::Put, body, headers)
    end

    # DELETEs to url
    def delete url, body = nil, headers = {}
      http_request(url, Net::HTTP::Delete, body, headers)
    end

    # a block that will be called when a remote server responds with
    # 401 Unauthorized, so that your application can prompt for
    # authentication details.
    #
    # the default is to use the values of @user and @pass.
    #
    # your block will be called with two parameters:
    # abs_url:: the base URL of the request URL
    # realm:: the realm used in the WWW-Authenticate header (maybe nil)
    #
    # your block should return [username, password], or nil
    def when_auth &block # :yields: abs_url, realm
      @get_auth_details = block
    end

    # GET a URL and turn it into an Atom::Entry
    def get_atom_entry(url)
      res = get(url, "Accept" => "application/atom+xml")

      # XXX handle other HTTP codes
      if res.code != "200"
        raise Atom::HTTPException, "failed to fetch entry: expected 200 OK, got #{res.code}"
      end

      # be picky for atom:entrys
      res.validate_content_type( [ "application/atom+xml" ] )

      Atom::Entry.parse(res.body, url)
    end

    # PUT an Atom::Entry to a URL
    def put_atom_entry(entry, url = entry.edit_url)
      raise "Cowardly refusing to PUT a non-Atom::Entry (#{entry.class})" unless entry.is_a? Atom::Entry
      headers = {"Content-Type" => "application/atom+xml" }

      put(url, entry.to_s, headers)
    end

    private
    # parses plain quoted-strings
    def parse_quoted_wwwauth param_string
      params = {}

      param_string.gsub(/(\w+)="(.*?)"/) { params[$1.to_sym] = $2 }

      params
    end

    # HTTP Basic authentication (RFC 2617)
    def basic_authenticate(req, url, param_string = "")
      params = parse_quoted_wwwauth(param_string)

      user, pass = username_and_password_for_realm(url, params[:realm])

      req.basic_auth user, pass
    end

    # is this the right way to do it? who knows, there's no
    # spec!
    #   <http://necronomicorp.com/lab/atom-authentication-sucks>
    #
    # thanks to H. Miyamoto for clearing things up.
    def wsse_authenticate(req, url, params = {})
      user, pass = username_and_password_for_realm(url, params["realm"])

      nonce = rand(16**32).to_s(16)
      nonce_enc = [nonce].pack('m').chomp
      now = Time.now.gmtime.iso8601

      digest = [Digest::SHA1.digest(nonce + now + pass)].pack("m").chomp

      req['X-WSSE'] = %Q<UsernameToken Username="#{user}", PasswordDigest="#{digest}", Nonce="#{nonce_enc}", Created="#{now}">
      req["Authorization"] = 'WSSE profile="UsernameToken"'
    end

    def authsub_authenticate req, url, param_string = ""
      req["Authorization"] = %{AuthSub token="#{@token}"}
    end

    # GoogleLogin support thanks to Adrian Hosey
    def googlelogin_authenticate(req, url, param_string)
      params_h = Hash.new
      param_string.split(',').each do |p|
        k, v = p.split('=')
        # No whitespace in the key
        k.delete!(' ')
        # Values come wrapped in doublequotes - remove
        v.gsub!(/^"|"$/, '')
        params_h[k] = v
      end

      abs_url = (url + "/").to_s
      user, pass = @get_auth_details.call(abs_url, params_h["realm"])
      token = fetch_googlelogin_token(user, pass, params_h["realm"], params_h["service"])
      if !token.nil?
        req["Authorization"] = "GoogleLogin auth=#{token}"
      end
    end

    def fetch_googlelogin_token(user, pass, url_s, service)
      req, url = new_request(url_s, Net::HTTP::Post)
      http_obj = Net::HTTP.new(url.host, url.port)
      if url.scheme == "https"
        http_obj.use_ssl = true
        probe_for_cafile(http_obj)
      end

      body = "Email=#{CGI.escape(user)}&Passwd=#{CGI.escape(pass)}&service=#{CGI.escape(service)}"
      body += "&accountType=GOOGLE&source=ruby-atom-tools-#{CGI.escape(TOOLS_VERSION)}"
      res = http_obj.start do |h|
        h.request(req, body)
      end

      retval = nil
      case res
      when Net::HTTPUnauthorized
        raise Unauthorized, "Your authorization was rejected"
      when Net::HTTPOK, Net::HTTPNonAuthoritativeInformation
        res.body.each_line do |l|
          k, v = l.split('=')
          if k == "Auth"
            retval = v.chomp
          end
        end
      end

      retval
    end

    # Look for a root CA file and set the relevant options on the passed-in Net::HTTP object.
    def probe_for_cafile(http_obj)
      ca_possibles = [
        '/usr/share/curl/curl-ca-bundle.crt', # OS X
        '/etc/pki/tls/certs/ca-bundle.crt', # newer Redhat
        '/usr/share/ssl/certs/ca-bundle.crt', # older Redhat
        '/etc/ssl/certs/ca-certificates.crt', # Ubuntu (I think)
        # <irony>Dear LSB: Thank you for standardizing Linux</irony>
      ]
      cafile = nil
      ca_possibles.each do |ca|
        if File.exist? ca
          cafile = ca
          break
        end
      end
      if cafile.nil?
        if @strict_ssl
          # set this knowing it will die, since we didn't find a good cafile
          http_obj.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          http_obj.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      else
        http_obj.ca_file = cafile
        http_obj.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http_obj.verify_depth = 5
      end
    end

    def username_and_password_for_realm(url, realm)
      abs_url = (url + "/").to_s
      user, pass = @get_auth_details.call(abs_url, realm)

      unless user and pass
        raise Unauthorized, "You must provide a username and password"
      end

      [ user, pass ]
    end

    # performs a generic HTTP request.
    def http_request(url_s, method, body = nil, headers = {}, www_authenticate = nil, redirect_limit = 5)
      cachekey = url_s.to_s

      cached_value = @cache[cachekey]
      if cached_value
        sock = Net::BufferedIO.new(StringIO.new(cached_value))
        info = Net::HTTPResponse.read_new(sock)
        info.reading_body(sock, true) {}

        if method == Net::HTTP::Put and info.key? 'etag' and not headers['If-Match']
          headers['If-Match'] = info['etag']
        end
      end

      if cached_value and not [Net::HTTP::Get, Net::HTTP::Head].member? method
        @cache.delete(cachekey)
      elsif cached_value
        entry_disposition = _entry_disposition(info, headers)

        if entry_disposition == :FRESH
          info.extend Atom::HTTPResponse

          return info
        elsif entry_disposition == :STALE
          if info.key? 'etag' and not headers['If-None-Match']
            headers['If-None-Match'] = info['etag']
          end
          if info.key? 'last-modified' and not headers['Last-Modified']
            headers['If-Modified-Since'] = info['last-modified']
          end
        end
      end

      req, url = new_request(url_s, method, headers)

      # two reasons to authenticate;
      if @always_auth
        self.send("#{@always_auth}_authenticate", req, url)
      elsif www_authenticate
        dispatch_authorization www_authenticate, req, url
      end

      http_obj = Net::HTTP.new(url.host, url.port)
      if url.scheme == "https"
        http_obj.use_ssl = true
        probe_for_cafile(http_obj)
      end

      res = http_obj.start do |h|
        h.request(req, body)
      end

      # a bit of added convenience
      res.extend Atom::HTTPResponse

      case res
      when Net::HTTPUnauthorized
        if @always_auth or www_authenticate or not res["WWW-Authenticate"] # XXX and not stale (Digest only)
          # we've tried the credentials you gave us once
          # and failed, or the server gave us no way to fix it
          raise Unauthorized, "Your authorization was rejected"
        else
          # once more, with authentication
          res = http_request(url_s, method, body, headers, res["WWW-Authenticate"])

          if res.kind_of? Net::HTTPUnauthorized
            raise Unauthorized, "Your authorization was rejected"
          end
        end
      when Net::HTTPRedirection
        if res.code == "304" and method == Net::HTTP::Get
          res.end2end_headers.each { |k| info[k] = res[k] }

          res = info

          res["Content-Length"] = res.body.length

          res.extend Atom::HTTPResponse

          _updateCache(headers, res, @cache, cachekey)
        elsif res["Location"] and (allow_all_redirects or [Net::HTTP::Get, Net::HTTP::Head].member? method)
          raise HTTPException, "Too many redirects" if redirect_limit.zero?

          res = http_request res["Location"], method, body, headers, nil, (redirect_limit - 1)
        end
      when Net::HTTPOK, Net::HTTPNonAuthoritativeInformation
        unless res.key? 'Content-Location'
          res['Content-Location'] = url_s
        end
        _updateCache(headers, res, @cache, cachekey)
      end

      res
    end

    def new_request(url_string, method, init_headers = {})
      headers = { "User-Agent" => UA }.merge(init_headers)

      url = url_string.to_uri

      rel = url.path
      rel += "?" + url.query if url.query

      [method.new(rel, headers), url]
    end

    def dispatch_authorization www_authenticate, req, url
      param_string = www_authenticate.sub(/^(\w+) /, "")
      auth_method = ($~[1].downcase + "_authenticate").to_sym

      if self.respond_to? auth_method, true # includes private methods
        self.send(auth_method, req, url, param_string)
      else
        # didn't support the first offered, find the next header
        next_to_try = www_authenticate.sub(/.* ([\w]+ )/, '\1')
        if next_to_try == www_authenticate
          # this was the last WWW-Authenticate header
          raise Atom::Unauthorized, "No support for offered authentication types"
        else
          dispatch_authorization next_to_try, req, url
        end
      end
    end
  end

  module HTTPResponse
    HOP_BY_HOP = ['connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'transfer-encoding', 'upgrade']

    # this should probably support ranges (eg. text/*)
    def validate_content_type( valid )
      raise Atom::HTTPException, "HTTP response contains no Content-Type!" if not self.content_type or self.content_type.empty?

      media_type = self.content_type.split(";").first

      unless valid.member? media_type.downcase
        raise Atom::WrongMimetype, "unexpected response Content-Type: #{media_type.inspect}. should be one of: #{valid.inspect}"
      end
    end

    def end2end_headers
      hopbyhop = HOP_BY_HOP
      if self['connection']
        hopbyhop += self['connection'].split(',').map { |x| x.strip }
      end
      @header.keys.reject { |x| hopbyhop.member? x.downcase }
    end
  end
end
