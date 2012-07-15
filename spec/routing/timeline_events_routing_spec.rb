require "spec_helper"

describe TimelineEventsController do
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

    it "routes to #edit" do
      get("/timeline_events/1/edit").should route_to("timeline_events#edit", :id => "1")
    end

    it "routes to #create" do
      post("/timeline_events").should route_to("timeline_events#create")
    end

    it "routes to #update" do
      put("/timeline_events/1").should route_to("timeline_events#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/timeline_events/1").should route_to("timeline_events#destroy", :id => "1")
    end

  end
end
