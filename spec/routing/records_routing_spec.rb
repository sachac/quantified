require "spec_helper"

describe RecordsController do
  describe "routing" do

    it "routes to #index" do
      get("/records").should route_to("records#index")
    end

    it "routes to #new" do
      get("/records/new").should route_to("records#new")
    end

    it "routes to #show" do
      get("/records/1").should route_to("records#show", :id => "1")
    end

    it "routes to #edit" do
      get("/records/1/edit").should route_to("records#edit", :id => "1")
    end

    it "routes to #create" do
      post("/records").should route_to("records#create")
    end

    it "routes to #update" do
      put("/records/1").should route_to("records#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/records/1").should route_to("records#destroy", :id => "1")
    end

  end
end
