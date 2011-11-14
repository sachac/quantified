require 'spec_helper'

describe "contexts/index.html.haml" do
  before(:each) do
    assign(:contexts, [
      stub_model(Context,
        :name => "Name",
        :rules => "MyText",
        :user_id => 1
      ),
      stub_model(Context,
        :name => "Name",
        :rules => "MyText",
        :user_id => 1
      )
    ])
  end

  it "renders a list of contexts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
