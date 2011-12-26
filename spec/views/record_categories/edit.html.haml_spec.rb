require 'spec_helper'

describe "record_categories/edit.html.haml" do
  before(:each) do
    @record_category = assign(:record_category, stub_model(RecordCategory,
      :name => "MyString",
      :parent_id => 1,
      :category_type => "MyString",
      :data => "MyText",
      :lft => 1,
      :rgt => 1
    ))
  end

  it "renders the edit record_category form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => record_categories_path(@record_category), :method => "post" do
      assert_select "input#record_category_name", :name => "record_category[name]"
      assert_select "input#record_category_parent_id", :name => "record_category[parent_id]"
      assert_select "input#record_category_category_type", :name => "record_category[category_type]"
      assert_select "textarea#record_category_data", :name => "record_category[data]"
      assert_select "input#record_category_lft", :name => "record_category[lft]"
      assert_select "input#record_category_rgt", :name => "record_category[rgt]"
    end
  end
end
