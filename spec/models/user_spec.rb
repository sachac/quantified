require 'rails_helper'
describe User do
  before :each do
    @user = FactoryGirl.create(:user)
  end
  it "adjusts the beginning of the week" do
    expect(@user.adjust_beginning_of_week(Time.zone.parse("June 3, 2013")).day).to eq 1
    expect(@user.adjust_beginning_of_week(Time.zone.parse("June 1, 2013")).day).to eq 1
  end

  it "adjusts the end of the week" do
    expect(@user.adjust_end_of_week(Time.zone.parse("May 1, 2014")).day).to eq 2
    expect(@user.adjust_end_of_week(Time.zone.parse("May 2, 2014")).day).to eq 2
    expect(@user.adjust_end_of_week(Time.zone.parse("May 3, 2014")).day).to eq 9
  end

  it "adjusts the end of the week" do
    travel_to Time.zone.parse("May 1, 2014")
    expect(@user.end_of_week.day).to eq 2
    travel_back
  end

  it "returns the beginning of this week" do
    expect(@user.beginning_of_week.wday).to eq 6
  end

  it "returns this week" do
    expect(@user.this_week.begin.wday).to eq 6
    expect(@user.this_week.end.wday).to eq 6
  end

  describe "#memento_mori" do
    it "updates the memento mori" do
      @user.birthdate = Time.zone.today
      @user.life_expectancy_in_years = 1
      @user.save!
      expect(@user.projected_end).to eq Time.zone.today + 1.year
    end

    it "can calculate days left" do
      @user.birthdate = Time.zone.today
      @user.life_expectancy_in_years = 1
      @user.save!
      expect(@user.memento_mori[:days]).to eq (Time.zone.today + 1.year - Time.zone.today).to_i
    end
  end

  describe "#get_location" do
    it "matches an existing location by ID" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      expect(@user.get_location(stuff.id.to_s)).to eq stuff
    end
    it "matches an existing location by name" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      expect(@user.get_location(stuff.name)).to eq stuff
    end
    it "creates a new location by name" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      location = @user.get_location(stuff.name + " new location")
      expect(location.class).to eq Stuff
      expect(location.stuff_type).to eq 'location'
      expect(location.name).to eq stuff.name + " new location"
      expect(location).to_not eq stuff
    end
    it "returns stuff if we pass it stuff" do
      stuff = FactoryGirl.create(:stuff, user: @user)
      location = @user.get_location(stuff)
      expect(location).to eq stuff
    end
  end

  it "checks for admin-ness" do
    expect(@user).to_not be_admin
    admin = FactoryGirl.create(:admin)
    expect(admin.admin?).to be true
  end

  it "considers the first account as the demo account" do
    demo_user = FactoryGirl.create(:demo_user)
    expect(demo_user).to be_demo
    u2 = FactoryGirl.create(:user)
    expect(u2).to_not be_demo
  end

  it "can find a record by username or email" do
    expect(User.find_record(@user.username)).to eq @user
    expect(User.find_record(@user.email)).to eq @user
    expect(User.find_record(@user.username + " boo")).to be_nil
  end

  it "can find for database authentication" do
    expect(User.find_for_database_authentication({login: @user.username})).to eq @user
    expect(User.find_for_database_authentication({login: @user.email})).to eq @user
    expect(User.find_for_database_authentication({login: @user.email + "xx"})).to be_nil
  end

  describe '#send_reset_password_instructions' do
    it 'sends mail if the user exists' do
      User.send_reset_password_instructions(:login => @user.email)
      expect(ActionMailer::Base.deliveries.last.to).to eq [@user.email]
    end
    it 'does not send mail if the user does not exist' do
      User.send_reset_password_instructions(:login => 'foo' + @user.email)
      expect(ActionMailer::Base.deliveries.last.to[0]).to_not eq('foo' + @user.email)
    end
  end

  describe '#find_recoverable_or_initialize_with_errors' do
    it 'works if the required attributes are specified and the record exists - search by email' do
      expect(User.find_recoverable_or_initialize_with_errors([:login], {:login => @user.email})).to eq @user
    end
    it 'works if the required attributes are specified and the record exists - search by username' do
      expect(User.find_recoverable_or_initialize_with_errors([:login], {:login => @user.username})).to eq @user
    end
    it 'returns an error if the login is not specified' do
      expect(User.find_recoverable_or_initialize_with_errors([:login], {:login => ''}).errors.size).to eq 1
    end
    it 'handles the case of a record not found' do
      expect(User.find_recoverable_or_initialize_with_errors([:login], {:login => @user.username + 'foo'}).errors.size).to eq 1
    end
  end
end
