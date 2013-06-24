require 'spec_helper'
describe Api::V1::RecordsController do
  describe 'POST create' do
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, :confirmed)
      sign_in @user
    end
    it "requires a category" do
      post :create, format: :json
      response.body.should match 'Please specify a category.'
    end
    it "requires an existing category" do
      post :create, category: 'ABC', format: :json
      response.body.should match 'Could not find matching category.'
    end
    it "creates a record if the category is unambiguous" do
      x = create(:record_category, user: @user, name: 'ABC')
      create(:record_category, user: @user, name: 'DEF')
      post :create, category: 'ABC', format: :json
      JSON.parse(response.body)['record_category_id'].should == x.id
    end
    context "when ambiguous" do
      before do
        create(:record_category, user: @user, name: 'ABC')
        create(:record_category, user: @user, name: 'ABCD')
      end
      it "returns the list in JSON if ambiguous" do
        post :create, category: 'ABC', format: :json
        response.body.should match 'Please disambiguate'
        response.body.should match 'ABCD'
      end
      it "returns XML if requested" do
        post :create, category: 'ABC', format: :xml
        response.body.should match 'Please disambiguate'
        response.body.should match '>ABCD<'
      end
    end
  end
end
