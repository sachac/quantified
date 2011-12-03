require 'spec_helper'

describe "tap_log_records/new.html.haml" do
  before(:each) do
    assign(:tap_log_record, stub_model(TapLogRecord).as_new_record)
  end

  it "renders new tap_log_record form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tap_log_records_path, :method => "post" do
    end
  end
end
