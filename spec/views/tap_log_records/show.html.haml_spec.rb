require 'spec_helper'

describe "tap_log_records/show.html.haml" do
  before(:each) do
    @tap_log_record = assign(:tap_log_record, Factory(:tap_log_record))
  end

  it "renders attributes" do
    render
  end
end
