require 'spec_helper'

describe "Clothing" do
  before :each do
    login
  end
  describe "GET /clothing" do
    it "shows active clothes" do
      get clothing_index_path
      response.status.should be(200)
    end
  end
end
