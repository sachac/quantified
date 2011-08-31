require "atom/http"
require "atom/feed"

module Atom
  class Categories < Atom::Element
    is_element PP_NS, 'categories'

    atom_elements :category, :list, Atom::Category

    attrb ['app', PP_NS], :scheme
    attrb ['app', PP_NS], :href

    def scheme= s
      list.each do |cat|
        unless cat.scheme
          cat.scheme = s
        end
      end
    end

    # 'fixed' attribute parsing/building
    attr_accessor :fixed

    on_parse_attr [PP_NS, :fixed] do |e,x|
      e.set(:fixed, x == 'yes')
    end

    on_build do |e,x|
      if e.get(:fixed)
        e.attributes['fixed'] = 'yes'
      end
    end
  end

  class Collection < Atom::Element
    is_element PP_NS, 'collection'

    strings ['app', PP_NS], :accept, :accepts
    attrb ['app', PP_NS], :href

    def_set :href do |href|
      @href = href
      @feed = Atom::Feed.new @href, @http
    end

    atom_element :title, Atom::Title

    elements ['app', PP_NS], :categories, :categories, Atom::Categories

    def title
      @title or @feed.title
    end

    def accepts
      if @accepts.empty?
        ['application/atom+xml;type=entry']
      else
        @accepts
      end
    end

    def accepts= array
      @accepts = array
    end

    attr_reader :http

    attr_reader :feed

    def initialize(href = nil, http = Atom::HTTP.new)
      super()

      @http = http

      if href
        self.href = href
      end
    end

    def self.parse xml, base = ''
      e = super

      # URL absolutization
      if !e.base.empty? and e.href
        e.href = (e.base.to_uri + e.href).to_s
      end

      e
    end

    # POST an entry to the collection, with an optional slug
    def post!(entry, slug = nil)
      raise "Cowardly refusing to POST a non-Atom::Entry" unless entry.is_a? Atom::Entry
      headers = {"Content-Type" => "application/atom+xml" }
      headers["Slug"] = slug if slug

      @http.post(@href, entry.to_s, headers)
    end

    # PUT an updated version of an entry to the collection
    def put!(entry, url = entry.edit_url)
      @http.put_atom_entry(entry, url)
    end

    # DELETE an entry from the collection
    def delete!(entry, url = entry.edit_url)
      @http.delete(url)
    end

    # POST a media item to the collection
    def post_media!(data, content_type, slug = nil)
      headers = {"Content-Type" => content_type}
      headers["Slug"] = slug if slug

      @http.post(@href, data, headers)
    end

    # PUT a media item to the collection
    def put_media!(data, content_type, slug = nil)
      headers = {"Content-Type" => content_type}

      @http.put(url, data, headers)
    end
  end
end
