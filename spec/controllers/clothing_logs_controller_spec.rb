require 'spec_helper'
describe ClothingLogsController do
  before :each do
    as_user
    @ability.can :manage, :all
    @b1 = Factory(:clothing, :tag_list => 'bottom', :user => @user)
    @b2 = Factory(:clothing, :tag_list => 'bottom', :user => @user)
    @t1 = Factory(:clothing, :tag_list => 'top', :user => @user)
    @t2 = Factory(:clothing, :tag_list => 'top', :user => @user)
    @d1 = Factory(:clothing, :tag_list => 'dress', :user => @user)
    @log1 = Factory(:clothing_log, :user => @user, :clothing => @b1, :date => Date.new(2011, 11, 1))
    @log2 = Factory(:clothing_log, :user => @user, :clothing => @t1, :date => Date.new(2011, 11, 1))
    @log3 = Factory(:clothing_log, :user => @user, :clothing => @b2, :date => Date.new(2011, 11, 2))
    @log4 = Factory(:clothing_log, :user => @user, :clothing => @b2, :date => Date.new(2011, 11, 2))
    @log5 = Factory(:clothing_log, :user => @user, :clothing => @b1, :date => Date.new(2011, 11, 3))
    @log6 = Factory(:clothing_log, :user => @user, :clothing => @b2, :date => Date.new(2011, 11, 3))
  end
  it "lets me view the index" do
    get :index
    d = assigns(:by_date)
    d[Date.new(2011, 11, 1)].should include @log1
    d[Date.new(2011, 11, 1)].should include @log2
    d[Date.new(2011, 11, 1)].should_not include @log3
    assigns(:dates).should == [Date.new(2011, 11, 3), Date.new(2011, 11, 2), Date.new(2011, 11, 1)]
  end

end
