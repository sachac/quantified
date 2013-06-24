require 'spec_helper'
describe TorontoLibrariesController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
  end
  describe 'POST /update' do
    it "refreshes the list" do
      card = create(:toronto_library, user: @user)
      TorontoLibrary.any_instance.should_receive(:refresh_items)
      post :refresh_all
    end
  end

end
