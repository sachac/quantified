require 'spec_helper'

describe Renderer do
  before do
    @user = create(:user, :confirmed)
    create(:user, :confirmed)
    @x = User.scoped.paginate :page => 1
    @renderer = Renderer::PaginationListLinkRenderer.new
    @renderer.prepare @x, {renderer: @renderer}, nil
  end
  describe '#html_container' do
    it "wraps it in a div" do
      @renderer.instance_eval do
        html_container('test')
      end.should match /div/
    end
    it "highlights the page number if active" do
      @renderer.instance_eval do
        stub(:link).and_return('x')
        page_number(1)
      end.should match /active/
    end
    it "does not highlight inactive page numbers" do
      @renderer.instance_eval do
        stub(:link).and_return('x')
        page_number(2)
      end.should_not match /active/
    end
    it "uses abbreviated classes for previous or next pages" do
      @renderer.instance_eval do
        previous_or_next_page('/time', 'Previous', 'previous_page')
      end.should match /prev /
    end
    it "disables gap links" do
      @renderer.instance_eval do
        @template = 'x'
        @template.stub!(:will_paginate_translate).and_return('...')
        gap
      end.should match /disabled/
    end
  end
end
