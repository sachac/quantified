require 'spec_helper'
describe Api::Offline::V1::OfflineController, :type => :controller  do
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
        expect(assigns(:categories)).to include(@cat)
      end
    end
    describe 'POST bulk_track' do
      it "tracks time if record category ID and date are specified" do
        post :bulk_track, record_category_id: @cat.id, date: '1372085012000', data: {:name => {'name' => 'note', 'value' => 'hello world'}}
        # Converted from unix timestamp
        expect(assigns(:record).timestamp.month).to eq 6
        expect(assigns(:record).timestamp.day).to eq 24
        expect(assigns(:record).data['note']).to eq 'hello world'
      end
      it "updates record if necessary" do
        post :bulk_track, record_category_id: @cat.id, date: '1372085012000'
        post :bulk_track, record_category_id: @cat2.id, date: '1372085012000'
        # Converted from unix timestamp
        expect(assigns(:record).timestamp.month).to eq 6
        expect(assigns(:record).timestamp.day).to eq 24
      end
      it "requires a category" do
        post :bulk_track, record_category_id: -1, type: 'track', format: :json, date: '1372085012000'
        expect(response.status).to eq 404
      end
      it "edits records" do
        rec = create(:record, record_category: @cat, user: @user)
        post :bulk_track, type: 'edit', id: rec.id, data: {0 => {'name' => 'note', 'value' => 'hello world'}}
        expect(rec.reload.data['note']).to eq 'hello world'
      end
      it "requires a valid operation" do
        post :bulk_track, type: 'blah'
        expect(response.status).to eq 500
      end
    end
  end
  context "when logged out" do
    it "does not allow tracking" do
      post :bulk_track
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
