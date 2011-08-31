require "time"
require "rexml/element"

require 'uri'

module URI # :nodoc: all
  class Generic; def to_uri; self; end; end
end

class String # :nodoc:
  def to_uri; URI.parse(self); end
end

# cribbed from metaid.rb
class Object
   # The hidden singleton lurks behind everyone
   def metaclass; class << self; self; end; end
   def meta_eval &blk; metaclass.instance_eval &blk; end

   # Adds methods to a metaclass
   def meta_def name, &blk
     meta_eval { define_method name, &blk }
   end
end

module Atom # :nodoc:
  NS = "http://www.w3.org/2005/Atom"
  PP_NS = "http://www.w3.org/2007/app"

  class ParseError < StandardError; end

  module AttrEl
    # for backwards compatibility
    def [] k; self.send(k.to_sym); end
    def []= k, v; self.send("#{k}=".to_sym, v); end
  end

  # ignore the man behind the curtain.
  def self.Multiple klass
    Class.new(Array) do
      @class = klass

      def new *args
        item = self.class.holds.new *args
        self << item

        item
      end

      def << item
        raise ArgumentError, "this can only hold items of class #{self.class.holds}" unless item.is_a? self.class.holds

        super(item)
      end

      def self.holds; @class end
      def self.single?; true end
      def taguri; end
    end
  end

  module Parsers
    # adds a parser that calls the given block for a single element that
    # matches the given name and namespace (if it exists)
    def on_parse name_pair, &block
      uri, name = name_pair
      @on_parse ||= []

      process = lambda do |e,x|
        el = e.get_elem(x, uri, name)

        if el
          block.call e, el

          e.extensions.delete_if do |c|
            c.namespace == uri and c.name == name.to_s
          end
        end
      end

      @on_parse << process
    end

    # adds a parser that calls the given block for the attribute that
    # matches the given name (if it exists)
    def on_parse_attr name_pair, &block
      uri, name = name_pair
      @on_parse ||= []

      process = lambda do |e,x|
        x = e.get_atom_attrb(x, name)

        if x
          block.call e, x

          e.extensions.attributes.delete name.to_s
        end
      end

      @on_parse << process
    end

    # adds a parser that calls the given block for all elements
    # that match the given name and namespace
    def on_parse_many name_pair, &block
      uri, name = name_pair
      @on_parse ||= []

      process = lambda do |e,x|
        els = e.get_elems(x, uri, name)

        unless els.empty?
          block.call e, els

          els.each do |el|
            e.extensions.delete_if { |c| c.namespace == uri and c.name == name.to_s }
          end
        end
      end

      @on_parse << process
    end

    # adds a parser that calls the given block for this element
    def on_parse_root &block
      @on_parse ||= []

      process = lambda do |e,x|
        block.call e, x

        x.elements.each do |el|
          e.extensions.clear
        end
      end

      @on_parse << process
    end

    # parses the text content of an element named 'name' into an attribute
    # on this Element named 'name'
    def parse_plain uri, name
      self.on_parse [uri, name] do |e,x|
        e.set(name, x.text)
      end
    end
  end

  module Converters
    def build_plain ns, name
      self.on_build do |e,x|
        if v = e.get(name)
          el = e.append_elem(x, ns, name)
          el.text = v.to_s
        end
      end
    end

    # an element in the Atom namespace containing text
    def atom_string(name)
      attr_accessor name

      self.parse_plain(Atom::NS, name)
      self.build_plain(['atom', Atom::NS], name)
    end

    # an element in namespace 'ns' containing a RFC3339 timestamp
    def time(ns, name)
      attr_reader name

      self.def_set name do |time|
        unless time.respond_to? :iso8601
          time = Time.parse(time.to_s)
        end

        def time.to_s; iso8601; end

        instance_variable_set("@#{name}", time)
      end

      define_method "#{name}!".to_sym do
        set(name, Time.now)
      end

      self.parse_plain(ns[1], name)
      self.build_plain(ns, name)
    end

    # an element in the Atom namespace containing a timestamp
    def atom_time(name)
      self.time ['atom', Atom::NS], name
    end

    # an element that is parsed by Element descendant 'klass'
    def element(ns, name, klass)
      el_name = name
      name = name.to_s.gsub(/-/, '_')

      attr_reader name

      self.on_parse [ns[1], el_name] do |e,x|
        e.instance_variable_set("@#{name}", klass.parse(x, e.base))
      end

      self.on_build do |e,x|
        if v = e.get(name)
          el = e.append_elem(x, ns, el_name)
          v.build(el)
        end
      end

      def_set name do |value|
        instance_variable_set("@#{name}", klass.new(value))
      end
    end

    # an element that is parsed by Element descendant 'klass'
    def atom_element(name, klass)
      self.element(['atom', Atom::NS], name, klass)
    end

    # an element that can appear multiple times that contains text
    #
    # 'one_name' is the name of the element, 'many_name' is the name of
    # the attribute that will be created on this Element
    def strings(ns, one_name, many_name)
      attr_reader many_name

      self.on_init do
        instance_variable_set("@#{many_name}", [])
      end

      self.on_parse_many [ns[1], one_name] do |e,xs|
        var = e.instance_variable_get("@#{many_name}")

        xs.each do |el|
          var << el.text
        end
      end

      self.on_build do |e,x|
        e.instance_variable_get("@#{many_name}").each do |v|
          e.append_elem(x, ns, one_name).text = v
        end
      end
    end

    # an element that can appear multiple times that is parsed by Element
    # descendant 'klass'
    #
    # 'one_name' is the name of the element, 'many_name' is the name of
    # the attribute that will be created on this Element
    def elements(ns, one_name, many_name, klass)
      attr_reader many_name

      self.on_init do
        var = Atom::Multiple(klass).new
        instance_variable_set("@#{many_name}", var)
      end

      self.on_parse_many [ns[1], one_name] do |e,xs|
        var = e.get(many_name)

        xs.each do |el|
          var << klass.parse(el, e.base)
        end
      end

      self.on_build do |e,x|
        e.get(many_name).each do |v|
          el = e.append_elem(x, ns, one_name)
          v.build(el)
        end
      end
    end

    # like #elements but in the Atom namespace
    def atom_elements(one_name, many_name, klass)
      self.elements(['atom', Atom::NS], one_name, many_name, klass)
    end

    # an XML attribute in the namespace 'ns'
    def attrb(ns, name)
      attr_accessor name

      self.on_parse_attr [ns[1], name] do |e,x|
        e.set(name, x)
      end

      self.on_build do |e,x|
        if v = e.get(name)
          n = name.to_s

          if x.namespace != ns[1]
            x.add_namespace *ns unless x.namespaces[ns[0]]
            n = "#{ns[0]}:#{n}"
          end

          x.attributes[n] = v.to_s
        end
      end
    end

    # an XML attribute in the Atom namespace
    def atom_attrb(name)
      self.attrb(['atom', Atom::NS], name)
    end

    # a type of Atom Link. specifics defined by Hash 'criteria'
    def atom_link name, criteria
      def_get name do
        existing = find_link(criteria)

        existing and existing.href
      end

      def_set name do |value|
        existing = find_link(criteria)

        if existing
          existing.href = value
        else
          links.new criteria.merge(:href => value)
        end
      end
    end
  end

  # The Class' methods provide a DSL for describing Atom's structure
  #   (and more generally for describing simple namespaced XML)
  class Element
    # this element's xml:base
    attr_accessor :base

    # xml elements and attributes that have been parsed, but are unknown
    attr_reader :extensions

    # attaches a name and a namespace to an element
    # this needs to be called on any new element
    def self.is_element ns, name
      meta_def :self_namespace do; ns; end
      meta_def :self_name do; name.to_s; end
    end

    # wrapper for #is_element
    def self.is_atom_element name
      self.is_element Atom::NS, name
    end

    # gets a single namespaced child element
    def get_elem xml, ns, name
      REXML::XPath.first xml, "./ns:#{name}", { 'ns' => ns }
    end

    # gets multiple namespaced child elements
    def get_elems xml, ns, name
      REXML::XPath.match xml, "./ns:#{name}", { 'ns' => ns }
    end

    # gets a child element in the Atom namespace
    def get_atom_elem xml, name
      get_elem xml, Atom::NS, name
    end

    # gets multiple child elements in the Atom namespace
    def get_atom_elems xml, name
      get_elems Atom::NS, name
    end

    # gets an attribute on +xml+
    def get_atom_attrb xml, name
      xml.attributes[name.to_s]
    end

    # sets an attribute on +xml+
    def set_atom_attrb xml, name, value
      xml.attributes[name.to_s] = value
    end

    extend Parsers
    extend Converters

    def self.on_build &block
      @on_build ||= []
      @on_build << block
    end

    def self.do_parsing e, root
      if ancestors[1].respond_to? :do_parsing
        ancestors[1].do_parsing e, root
      end

      @on_parse ||= []
      @on_parse.each { |p| p.call e, root }
    end

    def self.builders &block
      if ancestors[1].respond_to? :builders
        ancestors[1].builders &block
      end

      @on_build ||= []
      @on_build.each &block
    end

    # turns a String, an IO-like, a REXML::Element, etc. into an Atom::Element
    #
    # the 'base' base URL parameter should be supplied if you know where this
    # XML was fetched from
    #
    # if you want to parse into an existing Atom::Element, it can be passed in
    # as 'element'
    def self.parse xml, base = '', element = nil
      if xml.respond_to? :elements
         root = xml.dup
       else
         xml = xml.read if xml.respond_to? :read

         begin
           root = REXML::Document.new(xml.to_s).root
         rescue REXML::ParseException => e
           raise Atom::ParseError, e.message
         end
       end

      unless root.local_name == self.self_name
        raise Atom::ParseError, "expected element named #{self.self_name}, not #{root.local_name}"
      end

      unless root.namespace == self.self_namespace
        raise Atom::ParseError, "expected element in namespace #{self.self_namespace}, not #{root.namespace}"
      end

      if root.attributes['xml:base']
        base = (base.to_uri + root.attributes['xml:base'])
      end

      e = element ? element : self.new
      e.base = base

      # extension elements
      root.elements.each do |c|
        e.extensions << c
      end

      # extension attributes
      root.attributes.each do |k,v|
        e.extensions.attributes[k] = v
      end

      # as things are parsed, they're removed from e.extensions. whatever's
      # left over is stored so it can be round-tripped

      self.do_parsing e, root

      e
    end

    # converts to a REXML::Element
    def to_xml
      root = REXML::Element.new self.class.self_name
      root.add_namespace self.class.self_namespace

      build root

      root
    end

    # fill a REXML::Element with the data from this Atom::Element
    def build root
      if self.base and not self.base.empty?
        root.attributes['xml:base'] = self.base
      end

      self.class.builders do |builder|
        builder.call self, root
      end

      @extensions.each do |e|
        root << e.dup
      end

      @extensions.attributes.each do |k,v|
        root.attributes[k] = v
      end
    end

    def to_s
      to_xml.to_s
    end

    # defines a getter that calls 'block'
    def self.def_get(name, &block)
      define_method name.to_sym, &block
    end

    # defines a setter that calls 'block'
    def self.def_set(name, &block)
      define_method "#{name}=".to_sym, &block
    end

    # be sure to call #super if you override this method!
    def initialize defaults = {}
      @extensions = []

      @extensions.instance_variable_set('@attrs', {})
      def @extensions.attributes
        @attrs
      end

      self.class.run_initters do |init|
        self.instance_eval &init
      end

      defaults.each do |k,v|
        set(k, v)
      end
    end

    def self.on_init &block
      @on_init ||= []
      @on_init << block
    end

    def self.run_initters &block
      @on_init.each(&block) if @on_init
    end

    # appends an element named 'name' in namespace 'ns' to 'root'
    # ns is either [prefix, namespace] or just a String containing the namespace
    def append_elem(root, ns, name)
      if ns.is_a? Array
        prefix, uri = ns
      else
        prefix, uri = nil, ns
      end

      name = name.to_s

      existing_prefix = root.namespaces.find do |k,v|
        v == uri
      end

      root << if existing_prefix
                prefix = existing_prefix[0]

                if prefix != 'xmlns'
                  name = prefix + ':' + name
                end

                REXML::Element.new(name)
              elsif prefix
                e = REXML::Element.new(prefix + ':' + name)
                e.add_namespace(prefix, uri)
                e
              else
                e = REXML::Element.new(name)
                e.add_namespace(uri)
                e
              end
    end

    def base= uri # :nodoc:
      @base = uri.to_s
    end

    # calls a getter
    def get name
      send "#{name}".to_sym
    end

    # calls a setter
    def set name, value
      send "#{name}=", value
    end
  end

  # A link has the following attributes:
  #
  # href (required):: the link's IRI
  # rel:: the relationship of the linked item to the current item
  # type:: a hint about the media type of the linked item
  # hreflang:: the language of the linked item (RFC3066)
  # title:: human-readable information about the link
  # length:: a hint about the length (in octets) of the linked item
  class Link < Atom::Element
    is_atom_element :link

    atom_attrb :href
    atom_attrb :rel
    atom_attrb :type
    atom_attrb :hreflang
    atom_attrb :title
    atom_attrb :length

    include AttrEl

    def rel
      @rel or 'alternate'
    end

    def self.parse xml, base = ''
      e = super

      # URL absolutization
      if !e.base.empty? and e.href
        e.href = (e.base.to_uri + e.href).to_s
      end

      e
    end
  end

  # A category has the following attributes:
  #
  # term (required):: a string that identifies the category
  # scheme:: an IRI that identifies a categorization scheme
  # label:: a human-readable label
  class Category < Atom::Element
    is_atom_element :category

    atom_attrb :term
    atom_attrb :scheme
    atom_attrb :label

    include AttrEl
  end

  # A person construct has the following child elements:
  #
  # name (required):: a human-readable name
  # uri:: an IRI associated with the person
  # email:: an email address associated with the person
  class Person < Atom::Element
    atom_string :name
    atom_string :uri
    atom_string :email
  end

  class Author < Atom::Person
    is_atom_element :author
  end

  class Contributor < Atom::Person
    is_atom_element :contributor
  end

  module HasLinks
    def HasLinks.included(klass)
      klass.atom_elements :link, :links, Atom::Link
    end

    def find_link(criteria)
      self.links.find do |l|
        criteria.all? { |k,v| l.send(k) == v }
      end
    end
  end

  module HasCategories
    def HasCategories.included(klass)
      klass.atom_elements :category, :categories, Atom::Category
    end

    # categorize the entry with each of an array or a space-separated
    #   string
    def tag_with(tags, delimiter = ' ')
      return if not tags or tags.empty?

      tag_list = unless tags.is_a?(String)
                   tags
                 else
                   tags = tags.split(delimiter)
                   tags.map! { |t| t.strip }
                   tags.reject! { |t| t.empty? }
                   tags.uniq
                 end

      tag_list.each do |tag|
        unless categories.any? { |c| c.term == tag }
          categories.new :term => tag
        end
      end
    end
  end
end
