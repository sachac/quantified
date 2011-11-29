require "spec_helper"

describe MemoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/memories").should route_to("memories#index")
    end

    it "routes to #new" do
      get("/memories/new").should route_to("memories#new")
    end

    it "routes to #show" do
      get("/memories/1").should route_to("memories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/memories/1/edit").should route_to("memories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/memories").should route_to("memories#create")
    end

    it "routes to #update" do
      put("/memories/1").should route_to("memories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/memories/1").should route_to("memories#destroy", :id => "1")
    end

  end
end
