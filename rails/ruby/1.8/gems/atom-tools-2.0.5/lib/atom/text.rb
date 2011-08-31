require "atom/element"

module XHTML
  NS = "http://www.w3.org/1999/xhtml"
end

module Atom
  # An Atom::Element representing a text construct.
  # It has a single attribute, "type", which specifies how to interpret
  # the element's content. Different types are:
  #
  # text:: a plain string, without any markup (default)
  # html:: a chunk of HTML
  # xhtml:: a chunk of *well-formed* XHTML
  #
  # You should set this attribute appropriately after you set a Text
  # element (entry.content, entry.title or entry.summary).
  #
  # This content of this element can be retrieved in different formats, see #html and #xml
  class Text < Atom::Element
    atom_attrb :type

    include AttrEl

    on_parse_root do |e,x|
      type = e.type

      if x.is_a? REXML::Element
        if type == 'xhtml'
          x = e.get_elem x, XHTML::NS, 'div'

          raise Atom::ParseError, 'xhtml content needs div wrapper' unless x

          c = x.dup

          unless x.prefix.empty?
            # content has a namespace prefix, strip prefixes from it and all
            # XHTML children

            REXML::XPath.each(c, './/xhtml:*', 'xhtml' => XHTML::NS) do |x|
              x.name = x.name
            end
          end
        elsif ['text', 'html'].include?(type)
          c = x[0] ? x[0].value : nil
        else
          c = x
        end
      else
        c = x.to_s
      end

      e.instance_variable_set("@content", c)
    end

    on_build do |e,x|
      c = e.instance_variable_get('@content')
      if c.respond_to? :parent
        if c.is_a?(REXML::Element) && c.name == 'content' # && !c.text.strip == ''
          # c
          c.children.each do |child_element|
            x.add_element(child_element) unless child_element.is_a?(REXML::Text) && child_element.to_s.strip == ''
          end
          # x.add_text('') # unless child_element.to_s.strip == ''
        else
          x << c.dup
        end
      elsif c
        x.text = c.to_s
      end
    end

    def initialize value = nil
      super()

      @content = if value.respond_to? :to_xml
                   value.to_xml[0]
                 elsif value
                   value
                 else
                   ''
                 end
    end

    def type
      @type ? @type : 'text'
    end

    def to_s
      if type == 'xhtml' and @content and @content.name == 'div'
        @content.children.to_s
      else
        @content.to_s
      end
    end

    # returns a string suitable for dumping into an HTML document.
    #   (or nil if that's impossible)
    #
    # if you're storing the content of a Text construct, you probably
    # want this representation.
    def html
      if self["type"] == "xhtml" or self["type"] == "html"
        to_s
      elsif self["type"] == "text"
        REXML::Text.new(to_s).to_s
      end
    end

    # attempts to parse the content of this element as XML and return it
    # as an array of REXML::Elements.
    #
    # If self["type"] is "html" and Hpricot is installed, it will
    # be converted to XHTML first.
    def xml
      xml = REXML::Element.new 'div'

      if self["type"] == "xhtml"
        @content.children.each { |child| xml << child }
      elsif self["type"] == "text"
        xml.text = self.to_s
      elsif self["type"] == "html"
        begin
          require "hpricot"
        rescue
          raise "Turning HTML content into XML requires Hpricot."
        end

        fixed = Hpricot(self.to_s, :xhtml_strict => true)
        xml = REXML::Document.new("<div>#{fixed}</div>").root
      else
        # Not XHTML, HTML, or text - return the REXML::Element, leave it up to the user to parse the content
        xml = @content
      end

      xml
    end

    def inspect # :nodoc:
      "'#{to_s}'##{self['type']}"
    end

    def type= value
      unless valid_type? value
        raise Atom::ParseError, "atomTextConstruct type '#{value}' is meaningless"
      end

      @type = value
      if @type == "xhtml"
        begin
          parse_xhtml_content
        rescue REXML::ParseException
          raise Atom::ParseError, "#{@content.inspect} can't be parsed as XML"
        end
      end
    end

    private
    # converts @content based on the value of self["type"]
    def convert_contents e
      if self["type"] == "xhtml"
        @content
      elsif self["type"] == "text" or self["type"].nil? or self["type"] == "html"
        @content.to_s
      end
    end

    def valid_type? type
      ["text", "xhtml", "html"].member? type
    end

    def parse_xhtml_content xhtml = nil
      xhtml ||= @content

      @content = if xhtml.is_a? REXML::Element
        if xhtml.name == "div" and xhtml.namespace == XHTML::NS
          xhtml.dup
        else
          elem = REXML::Element.new("div")
          elem.add_namespace(XHTML::NS)

          elem << xhtml.dup

          elem
        end
      elsif xhtml.is_a? REXML::Document
        parse_xhtml_content xhtml.root
      else
        div = REXML::Document.new("<div>#{@content}</div>")
        div.root.add_namespace(XHTML::NS)

        div.root
      end
    end
  end

  # Atom::Content behaves the same as an Atom::Text, but for two things:
  #
  # * the "type" attribute can be an arbitrary media type
  # * there is a "src" attribute which is an URI that points to the content of the entry (in which case the content element will be empty)
  class Content < Atom::Text
    is_atom_element :content

    atom_attrb :src

    def src= v
      @content = nil

      if self.base
        @src = (self.base.to_uri + v).to_s
      else
        @src = v
      end
    end

    private
    def valid_type? type
      super or type.match(/\//)
    end

    def convert_contents e
      s = super

      s ||= if @content.is_a? REXML::Document
        @content.root
      elsif @content.is_a? REXML::Element
        @content
      else
        REXML::Text.normalize(@content.to_s)
      end

      s
    end
  end

  class Title < Atom::Text; is_atom_element :title; end
  class Subtitle < Atom::Text; is_atom_element :subtitle; end
  class Summary < Atom::Text; is_atom_element :summary; end
  class Rights < Atom::Text; is_atom_element :rights; end
end
