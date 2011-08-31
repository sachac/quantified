require File.dirname(__FILE__) + '/spec_helper'

require 'atom/feed'

describe Atom::Feed do
  describe 'extensions' do
    before(:each) do
      @feed = Atom::Feed.parse(fixtures('feed-w-ext'))
    end

    it 'should preserve namespaces' do
      @feed.to_s.should =~ /purl/

      feed2 = Atom::Feed.new
      feed2.merge! @feed

      feed2.to_s.should =~ /purl/
    end
  end

  before :each do
    @feed = Atom::Feed.parse(fixtures('contacts-feed'))
  end

  describe "to_s" do
    it "should only have one content element" do
      result = @feed.to_s
      result.scan("<content type=").size.should == 1
    end
  end

  describe "to_xml" do
    it "should only have one content element" do
      result = @feed.to_xml
      REXML::XPath.match(result, "//content").size.should == 1
    end
  end

end
