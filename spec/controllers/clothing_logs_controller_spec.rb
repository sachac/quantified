require 'spec_helper'
describe ClothingLogsController do
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
      assigns(:clothing_log).clothing.should eq (c)
    end
    it "looks up clothing by name" do
      c = create(:clothing, user: @user)
      post :create, { clothing: c.name }
      assigns(:clothing).should eq(c)
      assigns(:clothing_log).clothing.should eq (c)
    end
    it "creates clothing by name" do
      post :create, { clothing: "red shirt" }
      assigns(:clothing).name.should == 'red shirt'
      assigns(:clothing_log).clothing.name.should == 'red shirt'
    end
    it "sets the date if specified" do
      post :create, { clothing: "red shirt", date: "2013-01-01" }
      assigns(:clothing_log).clothing.name.should == 'red shirt'
      assigns(:clothing_log).date.to_s.should == '2013-01-01'
    end
    it "sets the clothing log parameters if specified" do
      c = create(:clothing, user: @user)
      post :create, { clothing_log: { clothing_id: c.id, date: "2013-01-01" } }
      assigns(:clothing_log).date.to_s.should == '2013-01-01'
    end
    it "handles errors gracefully" do
      post :create
      assigns[:clothing_log].should be_new_record
      flash[:notice].should be_nil
      response.should render_template('new')
    end
  end
end
