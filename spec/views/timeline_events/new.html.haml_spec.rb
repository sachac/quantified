require 'spec_helper'

describe "timeline_events/new.html.haml" do
  before(:each) do
    assign(:timeline_event, stub_model(TimelineEvent).as_new_record)
  end

  it "renders new timeline_event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => timeline_events_path, :method => "post" do
    end
  end
end
