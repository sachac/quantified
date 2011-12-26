require 'spec_helper'

describe "record_categories/index.html.haml" do
  before(:each) do
    assign(:record_categories, [
      stub_model(RecordCategory,
        :name => "Name",
        :parent_id => 1,
        :category_type => "Category Type",
        :data => "MyText",
        :lft => 1,
        :rgt => 1
      ),
      stub_model(RecordCategory,
        :name => "Name",
        :parent_id => 1,
        :category_type => "Category Type",
        :data => "MyText",
        :lft => 1,
        :rgt => 1
      )
    ])
  end

  it "renders a list of record_categories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Category Type".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
