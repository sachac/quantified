require 'rails_helper'
describe UsersController, :type => :controller  do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @u2 = create(:user, :confirmed)
  end
  context "when logged in as an administrator" do
    before do
      @user = create(:user, :admin)
      sign_in @user
    end
    describe 'GET index' do
      it "returns the list" do
        get :index
        assigns(:users).should include(@u2)
      end
    end
    describe 'GET show' do
      it "displays the item" do
        get :show, id: @u2.id
        assigns(:user).should == @u2
      end
    end
    describe 'GET new' do
      it "displays the new form" do
        get :new
        assigns(:user).should be_new_record
      end
    end
    describe 'GET edit' do
      it "edits the item" do
        get :edit, id: @u2.id
        assigns(:user).should == @u2
      end
    end
    describe 'POST create' do
      it "creates an item" do
        post :create, user: { email: 'foo@example.com', password: 'foobar', password_confirmation: 'foobar' }
        assigns(:user).email.should eq 'foo@example.com'
        flash[:notice].should == I18n.t('user.created')
      end
    end
    describe 'PUT update' do
      it "updates the item" do
        put :update, id: @u2.id, user: { username: 'elvis' }
        assigns(:user).username.should eq 'elvis'
        flash[:notice].should eq I18n.t('user.updated')
        response.should redirect_to edit_user_url(@u2)
      end
    end
    describe 'DELETE destroy' do
      it "removes the item" do
        delete :destroy, id: @u2.id
        lambda { User.find(@u2.id) }.should raise_exception(ActiveRecord::RecordNotFound)
        response.should redirect_to(root_url)
      end
    end
  end
  context "when logged in as a regular user" do
    before do
      @user = create(:user, :admin)
      sign_in @u2
    end
    describe 'GET index' do
      it "returns the list" do
        get :index
        response.should redirect_to root_path
        flash[:error].should == I18n.t('error.access_denied_logged_in')
      end
    end
    describe 'GET show' do
      it "displays me if I'm the user" do
        get :show, id: @u2.id
        assigns(:user).should == @u2
      end
      it "does not show other users" do
        @u3 = create(:user)
        get :show, id: @u3.id
        response.should redirect_to root_path
        flash[:error].should == I18n.t('error.access_denied_logged_in')
      end
    end
    describe 'GET new' do
      it "displays the new form" do
        get :new
        response.should redirect_to root_path
        flash[:error].should == I18n.t('error.access_denied_logged_in')
      end
    end
    describe 'GET edit' do
      it "edits my profile" do
        get :edit, id: @u2.id
        assigns(:user).should == @u2
      end
    end
    describe 'POST create' do
      it "does not let me" do
        post :create
        response.should redirect_to root_path
        flash[:error].should == I18n.t('error.access_denied_logged_in')
      end
    end
    describe 'PUT update' do
      it "updates my account" do
        put :update, id: @u2.id, user: { username: 'potato' }
        assigns(:user).username.should eq 'potato'
        flash[:notice].should eq I18n.t('user.updated')
        flash[:error].should_not eq I18n.t('error.access_denied_logged_in')
        response.should redirect_to edit_user_url(@u2)
      end
      it "changes the password if specified" do
        put :update, id: @u2.id, user: { password: 'foobar', password_confirmation: 'foobar' }
        assigns(:user).password.should == 'foobar'
      end
      it "sets the timezone" do
        put :update, id: @u2.id, user: { settings: { time_zone: 'Eastern Time (US &amp; Canada)' } }
        assigns(:user).settings.timezone.should == 'Eastern Time (US &amp; Canada)'
      end
      it "doesn't let me change other people's accounts" do
        put :update, id: @user.id, user: { username: 'potato' }
        flash[:error].should eq I18n.t('error.access_denied_logged_in')
        response.should redirect_to root_path
      end
    end
    describe 'DELETE destroy' do
      it "allows me" do
        delete :destroy, id: @u2.id
        response.should redirect_to root_path
      end
    end
  end
end
