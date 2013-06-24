require 'spec_helper'
describe Api::Offline::V1::OfflineController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  context "when logged in" do
    before do
      @user = create(:user, :confirmed)
      @cat = create(:record_category, user: @user, data: {'note' => {key: 'note', label: 'Note', type: 'text'}})
      @cat2 = create(:record_category, user: @user, data: {'note' => {key: 'note', label: 'Note', type: 'text'}})
      sign_in @user
    end
    describe 'GET track' do
      it "returns the list of activities" do
        get :track
        assigns(:categories).should include(@cat)
      end
    end
    describe 'POST bulk_track' do
      it "tracks time if record category ID and date are specified" do
        post :bulk_track, record_category_id: @cat.id, date: '1372085012000', data: {:name => {'name' => 'note', 'value' => 'hello world'}}
        # Converted from unix timestamp
        assigns(:record).timestamp.month.should == 6
        assigns(:record).timestamp.day.should == 24
        assigns(:record).data['note'].should == 'hello world'
      end
      it "updates record if necessary" do
        post :bulk_track, record_category_id: @cat.id, date: '1372085012000'
        post :bulk_track, record_category_id: @cat2.id, date: '1372085012000'
        # Converted from unix timestamp
        assigns(:record).timestamp.month.should == 6
        assigns(:record).timestamp.day.should == 24
      end
      it "requires a category" do
        post :bulk_track, record_category_id: -1, type: 'track', format: :json, date: '1372085012000'
        response.status.should == 404
      end
      it "edits records" do
        rec = create(:record, record_category: @cat, user: @user)
        post :bulk_track, type: 'edit', id: rec.id, data: {0 => {'name' => 'note', 'value' => 'hello world'}}
        rec.reload.data['note'].should == 'hello world'
      end
      it "requires a valid operation" do
        post :bulk_track, type: 'blah'
        response.status.should == 500
      end
    end
  end
  context "when logged out" do
    it "does not allow tracking" do
      post :bulk_track
      response.should redirect_to(new_user_session_path)
    end
  end
end
