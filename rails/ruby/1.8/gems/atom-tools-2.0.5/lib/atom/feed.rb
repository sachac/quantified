require "atom/element"
require "atom/text"
require "atom/entry"

require "atom/http"

module Atom
  # this is just a forward declaration since atom/entry includes atom/feed and vice-versa.
  class Entry < Atom::Element # :nodoc:
  end

  class FeedGone < RuntimeError # :nodoc:
  end

  # A feed of entries. As an Atom::Element, it can be manipulated using
  # accessors for each of its child elements. You can set them with any
  # object that makes sense; they will be returned in the types listed.
  #
  # Feeds have the following children:
  #
  # id:: a universally unique IRI which permanently identifies the feed
  # title:: a human-readable title (Atom::Text)
  # subtitle:: a human-readable description or subtitle (Atom::Text)
  # updated:: the most recent Time the feed was modified in a way the publisher considers significant
  # generator:: the agent used to generate a feed
  # icon:: an IRI identifying an icon which visually identifies a feed (1:1 aspect ratio, looks OK small)
  # logo:: an IRI identifying an image which visually identifies a feed (2:1 aspect ratio)
  # rights:: rights held in and over a feed (Atom::Text)
  #
  # There are also +links+, +categories+, +authors+, +contributors+
  # and +entries+, each of which is an Array of its respective type and
  # can be used thusly:
  #
  #   entry = feed.entries.new
  #   entry.title = "blah blah blah"
  #
  class Feed < Atom::Element
    is_atom_element :feed

    attr_reader :uri

    # the Atom::Feed pointed to by link[@rel='previous']
    attr_reader :prev
    # the Atom::Feed pointed to by link[@rel='next']
    attr_reader :next

    # conditional get information from the last fetch
    attr_reader :etag, :last_modified

    atom_string :id
    atom_element :title, Atom::Title
    atom_element :subtitle, Atom::Subtitle

    atom_time :updated

    include HasLinks
    include HasCategories

    atom_elements :author, :authors, Atom::Author
    atom_elements :contributor, :contributors, Atom::Contributor

    atom_string :generator # XXX with uri and version attributes!
    atom_string :icon
    atom_string :logo

    atom_element :rights, Atom::Rights

    atom_elements :entry, :entries, Atom::Entry

    include Enumerable

    def inspect # :nodoc:
      "<#{@uri} entries: #{entries.length} title='#{title}'>"
    end

    # Create a new Feed that can be found at feed_uri and retrieved
    # using an Atom::HTTP object http
    def initialize feed_uri = nil, http = Atom::HTTP.new
      @entries = []
      @http = http

      if feed_uri
        @uri = feed_uri.to_uri
        self.base = feed_uri
      end

      super()
    end

    # iterates over a feed's entries
    def each &block
      @entries.each &block
    end

    def empty?
      @entries.empty?
    end

    # gets everything in the logical feed (could be a lot of stuff)
    # (see RFC 5005)
    def get_everything!
      self.update!

      prev = @prev
      while prev
        prev.update!

        self.merge_entries! prev
        prev = prev.prev
      end

      nxt = @next
      while nxt
        nxt.update!

        self.merge_entries! nxt
        nxt = nxt.next
      end

      self
    end

    # merges the entries from another feed into this one
    def merge_entries! other_feed
      other_feed.each do |entry|
        # TODO: add atom:source elements
        self << entry
      end
    end

    # like #merge, but in place
    def merge! other_feed
      [:id, :title, :subtitle, :updated, :rights, :logo, :icon].each do |p|
        if (v = other_feed.get(p))
          set p, v
        end
      end

      [:links, :categories, :authors, :contributors].each do |p|
        other_feed.get(p).each do |e|
          get(p) << e
        end
      end

      @extensions = other_feed.extensions

      merge_entries! other_feed
    end

    # merges "important" properties of this feed with another one,
    # returning a new feed
    def merge other_feed
      feed = self.clone

      feed.merge! other_feed

      feed
    end

    # fetches this feed's URL, parses the result and #merge!s
    # changes, new entries, &c.
    #
    # (note that this is different from Atom::Entry#updated!
    def update!
      raise(RuntimeError, "can't fetch without a uri.") unless @uri

      res = @http.get(@uri, "Accept" => "application/atom+xml")

      if @etag and res['etag'] == @etag
        # we're already all up to date
        return self
      elsif res.code == "410"
        raise Atom::FeedGone, "410 Gone (#{@uri})"
      elsif res.code != "200"
        raise Atom::HTTPException, "Unexpected HTTP response code: #{res.code}"
      end

      # we'll be forgiving about feed content types.
      res.validate_content_type(["application/atom+xml",
                                  "application/xml",
                                  "text/xml"])

      @etag = res["ETag"] if res["ETag"]

      xml = res.body

      coll = REXML::Document.new(xml)

      update_el = REXML::XPath.first(coll, "/atom:feed/atom:updated", { "atom" => Atom::NS } )

      # the feed hasn't been updated, don't do anything.
      if update_el and self.updated and self.updated >= Time.parse(update_el.text)
        return self
      end

      coll = self.class.parse(coll.root, self.base.to_s)
      merge! coll

      if abs_uri = next_link
        @next = self.class.new(abs_uri.to_s, @http)
      end

      if abs_uri = previous_link
        @prev = self.class.new(abs_uri.to_s, @http)
      end

      self
    end

    atom_link :previous_link, :rel => 'previous'
    atom_link :next_link, :rel => 'next'

    # adds an entry to this feed. if this feed already contains an
    # entry with the same id, the newest one is used.
    def << entry
      existing = entries.find do |e|
        e.id == entry.id
      end

      if not existing
        @entries << entry
      elsif not existing.updated or (existing.updated and entry.updated and entry.updated >= existing.updated)
        @entries[@entries.index(existing)] = entry
      end
    end
  end
end
