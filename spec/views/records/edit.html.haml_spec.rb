require 'spec_helper'

describe "records/edit.html.haml" do
  before(:each) do
    @record = assign(:record, stub_model(Record,
      :user_id => 1,
      :source => "MyString",
      :source_id => 1,
      :record_category_id => 1,
      :data => "MyText",
      :duration => 1
    ))
  end

  it "renders the edit record form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => records_path(@record), :method => "post" do
      assert_select "input#record_user_id", :name => "record[user_id]"
      assert_select "input#record_source", :name => "record[source]"
      assert_select "input#record_source_id", :name => "record[source_id]"
      assert_select "input#record_record_category_id", :name => "record[record_category_id]"
      assert_select "textarea#record_data", :name => "record[data]"
      assert_select "input#record_duration", :name => "record[duration]"
    end
  end
end
