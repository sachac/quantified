require 'spec_helper'

describe "memories/index.html.haml" do
  before(:each) do
    as_user
    assign(:memories, [
      stub_model(Memory),
      stub_model(Memory)
    ])
  end

  it "renders a list of memories" do
    render
  end
end
