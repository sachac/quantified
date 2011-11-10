require "spec_helper"

describe ContextsController do
  describe "routing" do

    it "routes to #index" do
      get("/contexts").should route_to("contexts#index")
    end

    it "routes to #new" do
      get("/contexts/new").should route_to("contexts#new")
    end

    it "routes to #show" do
      get("/contexts/1").should route_to("contexts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/contexts/1/edit").should route_to("contexts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/contexts").should route_to("contexts#create")
    end

    it "routes to #update" do
      put("/contexts/1").should route_to("contexts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/contexts/1").should route_to("contexts#destroy", :id => "1")
    end

  end
end
