require 'spec_helper'
describe ClothingController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
  end
  describe 'GET /clothing/1/logs.json' do
    it "returns all clothing logs" do
      c = create(:clothing, user: @user)
      log = create(:clothing_log, user: @user, clothing: c)
      get :clothing_logs, id: c.id, format: :json
      assigns(:logs).should == [log]
    end
  end
  describe 'POST /clothing/bulk' do
    before do
      @clothing = Array.new
      5.times do
        @clothing << create(:clothing, user: @user)
      end
      @ids = [@clothing[0].id, @clothing[1].id]
    end
    it "stores items" do
      post :bulk, bulk: @ids, op: I18n.t('app.clothing.actions.store')
      @clothing[0].reload.status.should == 'stored'
      @clothing[2].reload.status.should == 'active'
    end
    it "activates items" do
      @clothing[0].update_attributes(status: 'stored')
      @clothing[2].update_attributes(status: 'stored')
      post :bulk, bulk: @ids, op: I18n.t('app.clothing.actions.activate')
      @clothing[0].reload.status.should == 'active'
      @clothing[2].reload.status.should == 'stored'
    end
    it "donates items" do
      post :bulk, bulk: @ids, op: I18n.t('app.clothing.actions.donate')
      @clothing[0].reload.status.should == 'donated'
      @clothing[2].reload.status.should == 'active'
    end
  end
  describe 'GET /clothing/missing_info' do
    it "shows items missing images" do
      c1 = create(:clothing, user: @user, image_file_name: 'foo.png')
      c2 = create(:clothing, user: @user)
      get :missing_info
      assigns(:clothing).should include(c2)
      assigns(:clothing).should_not include(c1)
    end
  end
  describe 'POST /clothing/update_missing_info' do
    it "lets you bulk-update images" do
      c1 = create(:clothing, user: @user)
      c2 = create(:clothing, user: @user)
      post :update_missing_info, image: { c1.id => fixture_file_upload('/files/sample-color-ff0000.png') }
      assigns(:clothing).should include(c2)
      assigns(:clothing).should_not include(c1)
      c1.reload.image.should_not be_nil
    end
  end
  describe 'POST /clothing/1/delete_color' do
    it "removes the color" do
      c1 = create(:clothing, user: @user, color: 'ffffff,000000')
      post :delete_color, id: c1.id, color: 'ffffff'
      c1.reload.color.should == '000000'
      flash[:notice].should == 'Color removed.'
    end
    it "behaves gracefully if the color is not included" do
      c1 = create(:clothing, user: @user, color: 'ffffff,000000')
      post :delete_color, id: c1.id, color: 'cccccc'
      c1.reload.color.should == 'ffffff,000000'
      flash[:error].should == 'Could not remove color.'
    end
  end
  describe 'POST save_color' do
    it "takes the color from the image" do
      file = File.new('spec/fixtures/files/sample-color-ff0000.png')
      c1 = create(:clothing, user: @user, color: '000000', image: file)
      post :save_color, id: c1.id, x: 1, y: 1
      c1.reload.color.should == '000000,ffffff'
      response.should redirect_to c1
    end
  end

end
