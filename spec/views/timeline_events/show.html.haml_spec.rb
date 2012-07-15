require 'spec_helper'

describe "timeline_events/show.html.haml" do
  before(:each) do
    @timeline_event = assign(:timeline_event, stub_model(TimelineEvent))
  end

  it "renders attributes in <p>" do
    render
  end
end
