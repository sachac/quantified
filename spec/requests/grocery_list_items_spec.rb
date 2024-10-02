require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe "GroceryListItems", :type => :request do
  describe "GET /grocery_list_items" do
    it "shows all the items from the various grocery lists you have access to" do
      @user = FactoryGirl.create(:user, :confirmed)
      login_as @user, scope: :user
      get grocery_list_items_path
      expect(response).to have_http_status(200)
    end
  end
end
