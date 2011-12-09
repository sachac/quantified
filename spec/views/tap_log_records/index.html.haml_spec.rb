require 'spec_helper'

describe "tap_log_records/index.html.haml" do
  before(:each) do
    as_user
    Factory(:tap_log_record)
    Factory(:tap_log_record)
  end

  it "renders a list of tap_log_records" do
    assign(:tap_log_records, TapLogRecord.paginate(:page => 1))

    render
  end
end
