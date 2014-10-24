require "spec_helper"

describe TapLogRecordsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      get("/tap_log_records").should route_to("tap_log_records#index")
    end

    it "routes to #new" do
      get("/tap_log_records/new").should route_to("tap_log_records#new")
    end

    it "routes to #show" do
      get("/tap_log_records/1").should route_to("tap_log_records#show", :id => "1")
    end

    it "routes to #edit" do
      get("/tap_log_records/1/edit").should route_to("tap_log_records#edit", :id => "1")
    end

    it "routes to #create" do
      post("/tap_log_records").should route_to("tap_log_records#create")
    end

    it "routes to #update" do
      put("/tap_log_records/1").should route_to("tap_log_records#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/tap_log_records/1").should route_to("tap_log_records#destroy", :id => "1")
    end

  end
end
