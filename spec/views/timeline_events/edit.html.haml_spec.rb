require 'rails_helper'

describe "timeline_events/edit.html.haml", type: :view do
  before(:each) do
    @timeline_event = assign(:timeline_event, stub_model(TimelineEvent))
  end

  it "renders the edit timeline_event form" do
    render
    assert_select "form", :action => timeline_events_path(@timeline_event), :method => "post" do
    end
  end
end
