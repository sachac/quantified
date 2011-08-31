require "uri"

require "atom/http"
require "atom/element"
require "atom/collection"

module Atom
  class AutodiscoveryFailure < RuntimeError; end

  # an Atom::Workspace has a #title (Atom::Text) and #collections, an Array of Atom::Collection s
  class Workspace < Atom::Element
    is_element PP_NS, :workspace

    elements ['app', PP_NS], :collection, :collections, Atom::Collection
    atom_element :title, Atom::Title
  end

  # Atom::Service represents an Atom Publishing Protocol service
  # document. Its only child is #workspaces, which is an Array of
  # Atom::Workspace s
  class Service < Atom::Element
    is_element PP_NS, :service

    elements ['app', PP_NS], :workspace, :workspaces, Atom::Workspace

    # retrieves and parses an Atom service document.
    def initialize(service_url = "", http = Atom::HTTP.new)
      super()

      @http = http

      return if service_url.empty?

      base = URI.parse(service_url)

      rxml = nil

      res = @http.get(base, "Accept" => "application/atomsvc+xml")
      res.validate_content_type(["application/atomsvc+xml"])

      unless res.code == "200"
        raise Atom::HTTPException, "Unexpected HTTP response code: #{res.code}"
      end

      self.class.parse(res.body, base, self)
    end

    def collections
      self.workspaces.map { |ws| ws.collections }.flatten
    end

    # given a URL, attempt to find a service document
    def self.discover url, http = Atom::HTTP.new
      res = http.get(url, 'Accept' => 'application/atomsvc+xml, text/html')

      case res.content_type
      when /application\/atomsvc\+xml/
        Service.parse res.body, url
      when /html/
        begin
          require 'hpricot'
        rescue
          raise 'autodiscovering from HTML requires Hpricot.'
        end

        h = Hpricot(res.body)

        links = h.search('//link')

        service_links = links.select { |l| (' ' + l['rel'] + ' ').match(/ service /i) }

        unless service_links.empty?
          url = url.to_uri + service_links.first['href']
          return Service.new(url.to_s, http)
        end

        rsd_links = links.select { |l| (' ' + l['rel'] + ' ').match(/ EditURI /i) }

        unless rsd_links.empty?
          url = url.to_uri + rsd_links.first['href']
          return Service.from_rsd(url, http)
        end

        raise AutodiscoveryFailure, "couldn't find any autodiscovery links in the HTML"
      else
        raise AutodiscoveryFailure, "can't autodiscover from a document of type #{res.content_type}"
      end
    end

    def self.from_rsd url, http = Atom::HTTP.new
      rsd = http.get(url)

      doc = REXML::Document.new(rsd.body)

      atom = REXML::XPath.first(doc, '/rsd/service/apis/api[@name="Atom"]')

      unless atom
        raise AutodiscoveryFailure, "couldn't find an Atom link in the RSD"
      end

      url = url.to_uri + atom.attributes['apiLink']

      Service.new(url.to_s, http)
    end
  end
end
