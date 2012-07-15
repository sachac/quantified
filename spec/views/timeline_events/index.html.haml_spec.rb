require 'spec_helper'

describe "timeline_events/index.html.haml" do
  before(:each) do
    assign(:timeline_events, [
      stub_model(TimelineEvent),
      stub_model(TimelineEvent)
    ])
  end

  it "renders a list of timeline_events" do
    render
  end
end
