require 'spec_helper'

describe "memories/new.html.haml" do
  before(:each) do
    assign(:memory, stub_model(Memory).as_new_record)
  end

  it "renders new memory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => memories_path, :method => "post" do
    end
  end
end
