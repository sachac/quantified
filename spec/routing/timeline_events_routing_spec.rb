require "spec_helper"

describe TimelineEventsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      get("/timeline_events").should route_to("timeline_events#index")
    end

    it "routes to #new" do
      get("/timeline_events/new").should route_to("timeline_events#new")
    end

    it "routes to #show" do
      get("/timeline_events/1").should route_to("timeline_events#show", :id => "1")
    end

    it "routes to #destroy" do
      delete("/timeline_events/1").should route_to("timeline_events#destroy", :id => "1")
    end

  end
end
