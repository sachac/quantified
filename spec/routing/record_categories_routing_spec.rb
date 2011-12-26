require "spec_helper"

describe RecordCategoriesController do
  describe "routing" do

    it "routes to #index" do
      get("/record_categories").should route_to("record_categories#index")
    end

    it "routes to #new" do
      get("/record_categories/new").should route_to("record_categories#new")
    end

    it "routes to #show" do
      get("/record_categories/1").should route_to("record_categories#show", :id => "1")
    end

    it "routes to #edit" do
      get("/record_categories/1/edit").should route_to("record_categories#edit", :id => "1")
    end

    it "routes to #create" do
      post("/record_categories").should route_to("record_categories#create")
    end

    it "routes to #update" do
      put("/record_categories/1").should route_to("record_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/record_categories/1").should route_to("record_categories#destroy", :id => "1")
    end

  end
end
