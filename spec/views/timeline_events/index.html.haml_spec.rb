require 'rails_helper'

describe "timeline_events/index.html.haml", type: :view do
  it "renders a list of timeline_events" do
    FactoryGirl.create(:record)  # this also triggers a timeline event
    assign(:timeline_events, TimelineEvent.order('created_at DESC').paginate(:page => 1))
    render
  end
end
