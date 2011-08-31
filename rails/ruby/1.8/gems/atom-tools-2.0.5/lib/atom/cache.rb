# portions of this ported from httplib2 <http://code.google.com/p/httplib2/>
# copyright 2006, Joe Gregorio
#
# used under the terms of the MIT license

require "digest/md5"

def normalize_header_names _headers
  headers = {}
  _headers.each { |k,v| headers[k.downcase] = v }
  headers
end

def _parse_cache_control headers
  retval = {}
  headers = normalize_header_names(headers) if headers.is_a? Hash

  if headers['cache-control']
    parts = headers['cache-control'].split(',')
    parts.each do |part|
      if part.match(/=/)
        k, v = part.split('=').map { |p| p.strip }
        retval[k] = v
      else
        retval[part.strip] = 1
      end
    end
  end

  retval
end

def _updateCache request_headers, response, cache, cachekey
  cc = _parse_cache_control request_headers
  cc_response = _parse_cache_control response
  if cc['no-store'] or cc_response['no-store']
    cache.delete cachekey
  else
    result = "HTTP/#{response.http_version} #{response.code} #{response.message}\r\n"

    response.each_capitalized_name do |field|
      next if ['status', 'content-encoding', 'transfer-encoding'].member? field.downcase
      response.get_fields(field).each do |value|
        result += "#{field}: #{value}\r\n"
      end
    end

    cache[cachekey] = result + "\r\n" + response.body
  end
end

=begin
    Determine freshness from the Date, Expires and Cache-Control headers.

    We don't handle the following:

    1. Cache-Control: max-stale
    2. Age: headers are not used in the calculations.

    Not that this algorithm is simpler than you might think
    because we are operating as a private (non-shared) cache.
    This lets us ignore 's-maxage'. We can also ignore
    'proxy-invalidate' since we aren't a proxy.
    We will never return a stale document as
    fresh as a design decision, and thus the non-implementation
    of 'max-stale'. This also lets us safely ignore 'must-revalidate'
    since we operate as if every server has sent 'must-revalidate'.
    Since we are private we get to ignore both 'public' and
    'private' parameters. We also ignore 'no-transform' since
    we don't do any transformations.
    The 'no-store' parameter is handled at a higher level.
    So the only Cache-Control parameters we look at are:

    no-cache
    only-if-cached
    max-age
    min-fresh
=end
def _entry_disposition(response_headers, request_headers)
  request_headers = normalize_header_names(request_headers)

  cc = _parse_cache_control(request_headers)
  cc_response = _parse_cache_control(response_headers)

  if request_headers['pragma'] and request_headers['pragma'].downcase.match(/no-cache/)
    unless request_headers.key? 'cache-control'
      request_headers['cache-control'] = 'no-cache'
    end
    :TRANSPARENT
  elsif cc.key? 'no-cache'
    :TRANSPARENT
  elsif cc_response.key? 'no-cache'
    :STALE
  elsif cc.key? 'only-if-cached'
    :FRESH
  elsif response_headers.key? 'date'
    date = Time.rfc2822(response_headers['date'])
    diff = Time.now - date
    current_age = (diff > 0) ? diff : 0
    if cc_response.key? 'max-age'
      freshness_lifetime = cc_response['max-age'].to_i
    elsif response_headers.key? 'expires'
      expires = Time.rfc2822(response_headers['expires'])
      diff = expires - date
      freshness_lifetime = (diff > 0) ? diff : 0
    else
      freshness_lifetime = 0
    end

    if cc.key? 'max-age'
      freshness_lifetime = cc['max-age'].to_i
    end

    if cc.key? 'min-fresh'
      min_fresh = cc['min-fresh'].to_i
      current_age += min_fresh
    end

    if freshness_lifetime > current_age
      :FRESH
    else
      :STALE
    end
  end
end

module Atom
  # this cache never actually saves anything
  class NilCache
    def [] key
      nil
    end

    def []= key, value
      nil
    end

    def delete key
      nil
    end
  end

  # uses a local directory to store cache files
  class FileCache
    def initialize dir
      @dir = dir
    end

    def to_file(key)
      @dir + "/" + self.safe(key)
    end

    # turns a URL into a safe filename
    def safe filename
      filemd5 = MD5.hexdigest(filename)
      filename = filename.sub(/^\w+:\/\//, '')
      filename = filename.gsub(/[?\/:|]+/, ',')

      filename + "," + filemd5
    end

    def [] key
      File.read(self.to_file(key))
    rescue Errno::ENOENT
      nil
    end

    def []= key, value
      File.open(self.to_file(key), 'w') do |f|
        f.write(value)
      end
    end

    def delete key
      File.delete(self.to_file(key))
    end
  end
end
