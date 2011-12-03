require 'spec_helper'

describe "tap_log_records/edit.html.haml" do
  before(:each) do
    @tap_log_record = assign(:tap_log_record, stub_model(TapLogRecord))
  end

  it "renders the edit tap_log_record form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tap_log_records_path(@tap_log_record), :method => "post" do
    end
  end
end
