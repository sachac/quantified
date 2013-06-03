require 'spec_helper'
describe User do
  before :each do
    @user = FactoryGirl.create(:user)
  end
  it "adjusts the beginning of the week" do
    @user.adjust_beginning_of_week(Date.parse("June 3, 2013")).day.should == 1
    @user.adjust_beginning_of_week(Date.parse("June 1, 2013")).day.should == 1
  end

  it "returns the beginning of this week" do
    @user.beginning_of_week.wday.should == 6
  end

  it "returns this week" do
    @user.this_week.begin.wday.should == 6
    @user.this_week.end.wday.should == 6
  end

  it "returns this week in terms of time" do
    @user.week.begin.wday.should == 6
    @user.week.end.wday.should == Date.today.wday
  end

  describe "#memento_mori" do
    it "updates the memento mori" do
      @user.birthdate = Date.today
      @user.life_expectancy_in_years = 1
      @user.save!
      @user.projected_end.should == Date.today + 1.year
    end

    it "can calculate days left" do
      @user.birthdate = Date.today
      @user.life_expectancy_in_years = 1
      @user.save!
      @user.memento_mori[:days].should == ((Date.today + 1.year) - Date.today).to_i
    end
  end

  describe "#get_location" do
    it "matches an existing location by ID" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      @user.get_location(stuff.id.to_s).should == stuff
    end
    it "matches an existing location by name" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      @user.get_location(stuff.name).should == stuff
    end
    it "creates a new location by name" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      location = @user.get_location(stuff.name + " new location")
      location.class.should == Stuff
      location.stuff_type.should == 'location'
      location.name.should == stuff.name + " new location"
      location.should_not == stuff
    end
    it "returns stuff if we pass it stuff" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      location = @user.get_location(stuff)
      location.should == stuff
    end
  end

  it "checks for admin-ness" do
    @user.should_not be_admin
    admin = FactoryGirl.create(:admin)
    admin.admin?.should be_true
  end

  it "considers the first account as the demo account" do
    @user.id = 1
    @user.demo?.should be_true
    u2 = FactoryGirl.create(:user)
    u2.demo?.should_not be_true
  end

  it "can find a record by username or email" do
    User.find_record(@user.username).should == @user
    User.find_record(@user.email).should == @user
    User.find_record(@user.username + " boo").should be_nil
  end

  it "can find for database authentication" do
    User.find_for_database_authentication({login: @user.username}).should == @user
    User.find_for_database_authentication({login: @user.email}).should == @user
    User.find_for_database_authentication({login: @user.email + "xx"}).should be_nil
  end

  describe '#find_recoverable_or_initialize_with_errors' do
    it 'works if the required attributes are specified and the record exists - search by email' do
      User.find_recoverable_or_initialize_with_errors([:login], {:login => @user.email}).should == @user
    end
    it 'works if the required attributes are specified and the record exists - search by username' do
      User.find_recoverable_or_initialize_with_errors([:login], {:login => @user.username}).should == @user
    end
    it 'returns an error if the login is not specified' do
      User.find_recoverable_or_initialize_with_errors([:login], {:login => ''}).errors.size.should == 1
    end
    it 'handles the case of a record not found' do
      User.find_recoverable_or_initialize_with_errors([:login], {:login => @user.username + 'foo'}).errors.size.should == 1
    end
  end
end
