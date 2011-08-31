require File.dirname(__FILE__) + '/spec_helper'

require 'atom/entry'

module TestsXML
  def read_entry_xml xpath
    REXML::XPath.first(@entry.to_xml, xpath, { 'atom' => Atom::NS, 'app' => Atom::PP_NS })
  end
end

describe Atom::Entry do
  describe 'when parsing' do
    before(:each) do
      @entry = Atom::Entry.parse(fixtures(:entry))
      @empty_entry = '<entry xmlns="http://www.w3.org/2005/Atom" />'
    end

    it 'should read & parse input from an IO object' do
      input = mock('IO')
      input.should_receive(:read).and_return(@empty_entry)
      Atom::Entry.parse(input).should be_an_instance_of(Atom::Entry)
    end

    it 'should read & parse input from a string' do
      input = mock('string')
      input.should_receive(:to_s).and_return(@empty_entry)
      Atom::Entry.parse(input).should be_an_instance_of(Atom::Entry)
    end

    it 'should raise ParseError when invalid entry' do
      lambda { Atom::Entry.parse('<entry/>') }.should raise_error(Atom::ParseError)
    end

    it 'should parse title element correctly' do
      @entry.title.should be_is_a(Atom::Text)
      @entry.title['type'].should == 'text'
      @entry.title.to_s.should == 'Atom draft-07 snapshot'
    end

    it 'should parse id element correctly' do
      @entry.id.should == 'tag:example.org,2003:3.2397'
    end

    it 'should parse updated element correctly' do
      @entry.updated.should == Time.parse('2005-07-31T12:29:29Z')
    end

    it 'should parse published element correctly' do
      @entry.published.should == Time.parse('2003-12-13T08:29:29-04:00')
    end

    it 'should parse app:edited element correctly' do
      @entry.edited.should == Time.parse('2005-07-31T12:29:29Z')
    end

    it 'should parse app:control/draft element correctly' do
      @entry.draft?.should be_true
    end

    it 'should parse rights element correctly' do
      @entry.rights.should be_is_a(Atom::Text)
      @entry.rights['type'].should == 'text'
      @entry.rights.to_s.should == 'Copyright (c) 2003, Mark Pilgrim'
    end

    it 'should parse author element correctly' do
      @entry.authors.length.should == 1
      @entry.authors.first.name.should == 'Mark Pilgrim'
      @entry.authors.first.email.should == 'f8dy@example.com'
      @entry.authors.first.uri.should == 'http://example.org/'
    end

    it 'should parse contributor element correctly' do
      @entry.contributors.length.should == 2
      @entry.contributors.first.name.should == 'Sam Ruby'
      @entry.contributors[1].name.should == 'Joe Gregorio'
    end

    it 'should parse content element correctly' do
      @entry.content.should be_an_instance_of(Atom::Content)
      @entry.content['type'].should == 'xhtml'
      @entry.content.base.should == 'http://diveintomark.org/'
      @entry.content.to_s.strip.should == '<p><i>[Update: The Atom draft is finished.]</i></p>'
    end

    it 'should parse summary element correctly' do
      @entry.summary['type'].should == 'text'
      @entry.summary.to_s.should == 'Some text.'
    end

    it 'should parse links element correctly' do
      @entry.links.length.should == 2
      alternates = @entry.links.select { |l| l['rel'] == 'alternate' }
      alternates.length.should == 1
      alternates.first['href'].should == 'http://example.org/2005/04/02/atom'
      alternates.first['type'].should == 'text/html'
      @entry.links.last['rel'].should == 'enclosure'
      @entry.links.last['href'].should == 'http://example.org/audio/ph34r_my_podcast.mp3'
      @entry.links.last['type'].should == 'audio/mpeg'
    end

    it 'should parse category element correctly' do
      @entry.categories.first['term'].should == 'ann'
      @entry.categories.first['scheme'].should == 'http://example.org/cats'
    end

    it 'should parse source element correctly' do
      @entry.source.title.to_s.should == 'Atom Sample Feed'
      @entry.source.id.should == 'tag:example.org,2003:/'

      @entry.source.links.length.should == 1
      @entry.source.links.first.rel == 'self'

      @entry.source.authors.length.should == 0

      @entry.source.contributors.length.should == 1
      @entry.source.contributors.first.name == 'Mark Pilgrim'
    end
  end

  describe 'title element' do
    before(:each) do
      @entry = Atom::Entry.new
    end

    it 'should be nil if not defined' do
      @entry.title.should be_nil

      @entry.title.to_s.should == ''
    end

    it 'should accept a simple string' do
      @entry.title = '<clever thing here>'

      @entry.title.type.should == 'text'

      @entry.title.to_s.should == '<clever thing here>'
      @entry.title.html.should =~ /^&lt;clever thing/
      @entry.title.to_xml.to_s.should =~ /&lt;clever thing/
    end

    it 'should accept an HTML string' do
      @entry.title = 'even <em>cleverer</em>'
      @entry.title.type = 'html'

      @entry.title.type.should == 'html'

      @entry.title.to_s.should =~ /even <em>clever/
      @entry.title.html.should =~ /even <em>clever/
      @entry.title.to_xml.to_s.should =~ /even &lt;em/
    end

    it 'should accept an XHTML string' do
      @entry.title = 'the <strong>cleverest</strong>'
      @entry.title.type = 'xhtml'

      @entry.title.to_xml.to_s.should =~ /w3.org\/1999\/xhtml.>the <strong>/
      @entry.title.html.should =~ /the <strong>cleverest/
    end

    it 'should reject an ill-formed XHTML string' do
      @entry.title = 'the <strong>cleverest'
      lambda { @entry.title.type = 'xhtml' }.should raise_error(Atom::ParseError)
    end

    it 'should accept something like Atom::Text' do
      title = Atom::Title.new '<3'

      @entry.title = title
      @entry.title.type.should == 'text'

      @entry.title.to_xml.to_s.should =~ /&lt;3/
    end
  end

  describe 'updated element' do
    before(:each) do
      @entry = Atom::Entry.new
    end

    it 'should be nil if not defined' do
      @entry.updated.should be_nil
    end

    it 'should be definable' do
      @entry.updated = '1990-04-07'
      @entry.updated.should == Time.parse('1990-04-07')
    end

    it 'should be an xsd:DateTime' do
      @entry.updated = '1990-04-07'
      @entry.updated.to_s.should =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
    end

    it 'should be declarable as updated using #updated!' do
      @entry.updated!
      @entry.updated.should > Time.parse('1990-04-07')
    end
  end

  describe 'app:edited element' do
    include TestsXML

    before(:each) do
      @entry = Atom::Entry.new
    end

    it 'should be nil if not defined' do
      @entry.edited.should be_nil
    end

    it 'should be definable' do
      @entry.edited = '1990-04-07'
      @entry.edited.should == Time.parse('1990-04-07')
    end

    it 'should be an xsd:DateTime' do
      @entry.edited = '1990-04-07'
      @entry.edited.to_s.should =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
    end

    it 'should have APP namespace' do
      @entry.edited = '1990-04-07'
      read_entry_xml('app:edited').namespace.should == Atom::PP_NS
    end

    it 'should be declarable as edited using #edited!' do
      @entry.edited!
      @entry.edited.should > Time.parse('1990-04-07')
    end
  end

  describe 'category element' do
    before(:each) do
      @entry = Atom::Entry.new
    end

    it 'should have no category on intializing' do
      @entry.categories.should be_empty
    end

    it 'should increase total count when adding a new category' do
      @count = @entry.categories.length
      @entry.categories.new['term'] = 'foo'
      @entry.categories.length.should == @count + 1
    end

    it 'should find category' do
      category = @entry.categories.new
      category['scheme'] = 'http://example.org/categories'
      category['term'] = 'bar'
      @entry.categories.select { |c| c['scheme'] == 'http://example.org/categories' }.should == [category]
    end

    describe 'when using tags' do
      before(:each) do
        @tags = %w(chunky bacon ruby)
      end

      it 'should set categories from an array of tags' do
        @entry.tag_with(@tags)
        @entry.categories.length.should == 3
        @tags.each { |tag| @entry.categories.any? { |c| c['term'] == tag }.should be_true }
      end

      it 'should set categories from a space-sperated string of tags' do
        @entry.tag_with(@tags.join(' '))
        @entry.categories.length.should == 3
        @tags.each { |tag| @entry.categories.any? { |c| c['term'] == tag }.should be_true }
      end

      it 'should be possible to specify the delimiter when passing tags as a string' do
        @entry.tag_with(@tags.join(','), ',')
        @entry.categories.length.should == 3
        @tags.each { |tag| @entry.categories.any? { |c| c['term'] == tag }.should be_true }
      end

      it 'should create a category only once' do
        @entry.tag_with(@tags)
        @entry.tag_with(@tags.first)
        @entry.categories.length.should == 3
      end
    end
  end

  describe 'edit url' do
    before(:each) do
      @entry = Atom::Entry.new
    end

    it 'should be nil on initializing' do
      @entry.edit_url.should be_nil
    end

    it 'should be easily definable' do
      @entry.edit_url = 'http://example.org/entries/foo'
      @entry.edit_url.should == 'http://example.org/entries/foo'
    end

    it 'should not erase other links' do
      link = @entry.links.new :rel => 'related', :href => 'http://example.org'

      @entry.edit_url = 'http://example.com/entries/foo'
      @entry.links.length.should == 2
      @entry.links.should include(link)
    end

    it 'should accept a URI object' do
      @entry.edit_url = URI.parse('http://example.com/entries/foo')
      @entry.to_s.should =~ /example.com\/entries/
    end
  end

  describe 'draft element' do
    include TestsXML

    before(:each) do
      @entry = Atom::Entry.new
    end

    it 'should not be a draft by default' do
      @entry.should_not be_draft
    end

    it 'should be definable using draft=' do
      @entry.draft = true
      @entry.should be_draft
      @entry.draft = false
      @entry.should_not be_draft
    end

    it 'should be declarable as a draft using #draft!' do
      @entry.draft!
      @entry.should be_draft
    end

    it 'should have APP namespace' do
      @entry.draft!
      read_entry_xml('app:control/app:draft').namespace.should == Atom::PP_NS
    end
  end

  describe 'extensions' do
    before(:each) do
      @entry = Atom::Entry.parse(fixtures('entry-w-ext'))
    end

    it 'should preserve namespaces' do
      @entry.to_s.should =~ /purl/
    end
  end

  describe "with XML in the content element" do
    it "should expose the content XML" do
      @entry = Atom::Entry.parse(fixtures('entry-w-xml'))
      @entry.content.xml.should be_instance_of(REXML::Element)
    end

    it "should expose the content XML" do
      @entry = Atom::Entry.parse(fixtures('entry-w-xml'))
      @entry.content.xml.root.name.should_not == 'content'
    end
  end
end
