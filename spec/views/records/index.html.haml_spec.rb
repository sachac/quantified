require 'spec_helper'

describe "records/index.html.haml" do
  before(:each) do
    assign(:records, [
      stub_model(Record,
        :user_id => 1,
        :source => "Source",
        :source_id => 1,
        :record_category_id => 1,
        :data => "MyText",
        :duration => 1
      ),
      stub_model(Record,
        :user_id => 1,
        :source => "Source",
        :source_id => 1,
        :record_category_id => 1,
        :data => "MyText",
        :duration => 1
      )
    ])
  end

  it "renders a list of records" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Source".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
