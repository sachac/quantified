require File.dirname(__FILE__) + '/spec_helper'

require 'atom/service'

describe Atom::Service do
  describe 'when parsing' do
    before(:each) do
      @service = Atom::Service.parse(fixtures(:service))
    end

    it 'should parse workspace elements correctly' do
      @service.workspaces.length.should == 2
    end

    it 'should absolutize relative hrefs' do
      svc = Atom::Service.parse(
        fixtures('service-w-xhtml-ns'),
        'http://example.org/introspection/')

      coll = svc.workspaces.first.collections.first
      coll.href.should == "http://example.org/entries/?yanel.resource.viewid=atom"
    end

    it 'should parse XHTML outside the default namespace correctly' do
      xhtml_svc = Atom::Service.parse(fixtures('service-w-xhtml-ns'))

      xhtml_svc.workspaces.length.should == 2
      xhtml_coll = xhtml_svc.workspaces.last.collections.first
      xhtml_coll.title.html.strip.should == 'Yulup <b>Releases</b>'
    end
  end
end

describe Atom::Workspace do
  describe 'when parsing' do
    before(:each) do
      svc = Atom::Service.parse(fixtures(:service))
      @main = svc.workspaces.first
      @sidebar = svc.workspaces.last
    end

    it 'should parse title element correctly' do
      @main.title.to_s.should == 'Main Site'
      @sidebar.title.to_s.should == 'Sidebar Blog'
    end

    it 'should parse collection elements correctly' do
      @main.collections.length.should == 2
      @sidebar.collections.length.should == 1
    end
  end
end

describe Atom::Collection do
  describe 'when parsing' do
    before(:each) do
      svc = Atom::Service.parse(fixtures(:service))
      @entries = svc.workspaces.first.collections.first
      @pictures = svc.workspaces.first.collections.last
      @links = svc.workspaces.last.collections.first
    end

    it 'should parse href correctly' do
      @entries.href.should == 'http://example.org/blog/main'
      @entries.feed.uri.to_s.should == 'http://example.org/blog/main'

      @pictures.href.should == 'http://example.org/blog/pic'
      @links.href.should == 'http://example.org/sidebar/list'
    end

    it 'should parse title element correctly' do
      @entries.title.to_s.should == 'My Blog Entries'
      @pictures.title.to_s.should == 'Pictures'
      @links.title.to_s.should == 'Remaindered Links'
    end

    it 'should parse accept elements correctly' do
      @entries.accepts.should == ['application/atom+xml;type=entry']
      @pictures.accepts.should == ['image/png', 'image/jpeg', 'image/gif']
      @links.accepts.should == ['application/atom+xml;type=entry']
    end
  end
end

describe Atom::Categories do
  describe 'when parsing' do
    before(:each) do
      svc = Atom::Service.parse(fixtures(:service))
      @ool = svc.workspaces.first.collections.first.categories.first
      @il = svc.workspaces.last.collections.first.categories.first
    end

    it 'should parse out-of-line categories correctly' do
      @ool.href.should == 'http://example.com/cats/forMain.cats'
    end

    it 'should parse inline categories correctly' do
      @il.fixed.should be_true

      @il.list.length.should == 2

      @il.list.first.scheme.should == 'http://example.org/extra-cats/'
      @il.list.first.term.should == 'joke'

      @il.list.last.term.should == 'serious'
    end
  end
end
