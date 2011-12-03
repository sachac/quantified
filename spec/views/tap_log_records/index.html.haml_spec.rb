require 'spec_helper'

describe "tap_log_records/index.html.haml" do
  before(:each) do
    as_user
    assign(:tap_log_records, [
                              Factory(:tap_log_record),
                              Factory(:tap_log_record)
    ])
  end

  it "renders a list of tap_log_records" do
    render
  end
end
