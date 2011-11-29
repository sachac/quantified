require 'spec_helper'
describe ClothingController do
  before :each do
    as_user
    @ability.can :manage, :all
  end
  describe "analysis" do
    before :each do
      @user ||= Factory(:user)
      @b1 = Factory(:clothing, :tag_list => 'bottom', :user => @user)
      @b2 = Factory(:clothing, :tag_list => 'bottom', :user => @user)
      @t1 = Factory(:clothing, :tag_list => 'top', :user => @user)
      @t2 = Factory(:clothing, :tag_list => 'top', :user => @user)
      @d1 = Factory(:clothing, :tag_list => 'dress', :user => @user)
      Factory(:clothing_log, :date => Date.today, :clothing => @b1, :user => @user)
      Factory(:clothing_log, :date => Date.today, :clothing => @t1, :user => @user)
      Factory(:clothing_log, :date => Date.yesterday, :clothing => @b2, :user => @user)
      Factory(:clothing_log, :date => Date.yesterday, :clothing => @t2, :user => @user)
      Factory(:clothing_log, :date => Date.today - 2.days, :clothing => @b2, :user => @user)
      Factory(:clothing_log, :date => Date.today - 2.days, :clothing => @t1, :user => @user)
      Factory(:clothing_log, :date => Date.today - 3.days, :clothing => @d1, :user => @user)
    end
    it "analyzes use" do
      get :analyze
      tops = assigns(:tops)
      [@t1, @t2, @d1].each do |x|
        tops.should include [x.id, x]
      end
      [@b1, @b2].each do |x|
        tops.should_not include [x.id, x]
      end
      matches = assigns(:matches)
      matches[@b1.id][1][@t1.id].should include Date.today
      matches[@b2.id][1][@t2.id].should include Date.yesterday
      matches[@b2.id][1][@t1.id].should include Date.today - 2.days
      matches[@b1.id][1][@t2.id].should be_nil
      matches[0][1][@d1.id].should include Date.today - 3.days
    end
    it "graphs clothing" do
      Factory(:clothing_log, :date => Date.today - 5.days, :clothing => @b2, :user => @user)
      Factory(:clothing_log, :date => Date.today - 5.days, :clothing => @t2, :user => @user)
      get :graph
      tops = assigns(:tops)
      [@t1, @t2].each do |x|
        tops.should include x
      end
      [@b1, @b2, @d1].each do |x|
        tops.should_not include x
      end
      m = assigns(:matches)
      m[[@b2.id, @t1.id]].should == 1
      m[[@b2.id, @t2.id]].should == 2
      m[[@b1.id, @t1.id]].should == 1
    end
  end
  it "allows bulk updates" do
    @b1 = Factory(:clothing, :tag_list => 'bottom', :user => @user)
    @b2 = Factory(:clothing, :tag_list => 'bottom', :user => @user)
    post :bulk, :op => I18n.t('app.clothing.actions.store'), :bulk => [@b1.id]
    @b1.reload.status.should == 'stored'
    @b2.reload.status.should == 'active' 
    post :bulk, :op => I18n.t('app.clothing.actions.donate'), :bulk => [@b1.id]
    @b1.reload.status.should == 'donated'
    @b2.reload.status.should == 'active'
    post :bulk, :op => I18n.t('app.clothing.actions.activate'), :bulk => [@b1.id]
    @b1.reload.status.should == 'active'
    @b2.reload.status.should == 'active'
  end

  describe "with invalid params" do
    it "assigns a newly created but unsaved context as @context" do
      # Trigger the behavior that occurs when invalid params are submitted
      Clothing.any_instance.stub(:save).and_return(false)
      post :create, :clothing => {}
      assigns(:clothing).should be_a_new(Clothing)
      response.should render_template("new")
    end
    it "assigns the context as @context" do
      clothing = Factory(:clothing, :user => @user)
      # Trigger the behavior that occurs when invalid params are submitted
      Clothing.any_instance.stub(:save).and_return(false)
      put :update, :id => clothing.id, :clothing => {}
      assigns(:clothing).should eq(clothing)
      response.should render_template("edit")
    end
  end
end
