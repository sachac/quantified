require 'spec_helper'

describe "memories/edit.html.haml" do
  before(:each) do
    @memory = assign(:memory, Factory(:memory))
  end

  it "renders the edit memory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => memories_path(@memory), :method => "post" do
    end
  end
end
