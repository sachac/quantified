require 'spec_helper'
require 'will_paginate/array'

describe Renderer, :type => :helper do
  before do
    5.times do
      create(:user, :confirmed)
    end
    @x = User.paginate(page: 2, per_page: 2)
    allow(helper).to receive(:params).and_return({controller: 'users', action: 'index'})
  end
  describe '#to_html' do
    subject { helper.will_paginate(@x) }
    it "wraps it in a div" do
      expect(subject).to match /div/
    end
    it "highlights the page number if active" do
      expect(subject).to match /<li class="active"><a href="\/users\?page=2"/
    end
    it "does not highlight inactive page numbers" do
      expect(subject).to match /<li><a rel="next" href="\/users\?page=3"/
    end
    it "uses abbreviated classes for previous or next pages" do
      subject.should match /prev /
    end
    it "disables gap links" do
      subject.should_not match /\.\.\./
    end
  end
end
