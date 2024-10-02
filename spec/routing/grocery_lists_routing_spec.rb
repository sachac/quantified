require "rails_helper"

RSpec.describe GroceryListsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/grocery_lists").to route_to("grocery_lists#index")
    end

    it "routes to #new" do
      expect(:get => "/grocery_lists/new").to route_to("grocery_lists#new")
    end

    it "routes to #show" do
      expect(:get => "/grocery_lists/1").to route_to("grocery_lists#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/grocery_lists/1/edit").to route_to("grocery_lists#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/grocery_lists").to route_to("grocery_lists#create")
    end

    it "routes to #update" do
      expect(:put => "/grocery_lists/1").to route_to("grocery_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/grocery_lists/1").to route_to("grocery_lists#destroy", :id => "1")
    end

  end
end
