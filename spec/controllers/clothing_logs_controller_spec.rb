require 'spec_helper'
describe ClothingLogsController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, :confirmed)
    sign_in @user
    request.env["HTTP_REFERER"] = 'clothing_logs/index'
  end
  describe "POST create" do
    it "handles clothing IDs" do
      c = create(:clothing, user: @user)
      post :create, { clothing: c.id }
      assigns(:clothing).should eq(c)
      expect(assigns(:clothing_log).clothing).to eq (c)
    end
    it "looks up clothing by name" do
      c = create(:clothing, user: @user)
      post :create, { clothing: c.name }
      expect(assigns(:clothing)).to eq(c)
      expect(assigns(:clothing_log).clothing).to eq (c)
    end
    it "creates clothing by name" do
      post :create, { clothing: "red shirt" }
      expect(assigns(:clothing).name).to eq 'red shirt'
      expect(assigns(:clothing_log).clothing.name).to eq 'red shirt'
    end
    it "sets the date if specified" do
      post :create, { clothing: "red shirt", date: "2013-01-01" }
      expect(assigns(:clothing_log).clothing.name).to eq 'red shirt'
      expect(assigns(:clothing_log).date.to_s).to eq '2013-01-01'
    end
    it "sets the clothing log parameters if specified" do
      c = create(:clothing, user: @user)
      post :create, { clothing_log: { clothing_id: c.id, date: "2013-01-01" } }
      expect(assigns(:clothing_log).date.to_s).to eq '2013-01-01'
    end
    it "handles errors gracefully" do
      post :create
      expect(assigns[:clothing_log]).to be_new_record
      expect(flash[:notice]).to be_nil
      expect(response).to render_template('new')
    end
  end
end
