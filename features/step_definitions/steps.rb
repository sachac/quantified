When /^I go to the dashboard$/ do
  visit root_path
end

When /^I switch to the mobile layout$/ do
  click_link I18n.t('app.layout.mobile')
end

Then /^I should see the mobile layout$/ do
  page.should_not have_content I18n.t('app.layout.mobile')
end

When /^I go to the contexts page$/ do
  visit contexts_path
end

When /^I switch to the full layout$/ do
  click_link I18n.t('app.layout.full')
end

Then /^I should see the full layout$/ do
  page.should_not have_content I18n.t('app.layout.full')
end

When /^I am on the subdomain for "([^"]*)"$/ do |arg1|
  host! "#{arg1}.example.com"
  Capybara.app_host = "http://#{arg1}.example.com"
end

Then /^the current account should be "([^"]*)"$/ do |arg1|
  page.should have_content "quantified awesome: #{arg1}"
end

Then /^I should see an error$/ do
  page.body.should include 'error'
end

Given /^I am a user$/ do
  @user = FactoryGirl.create(:confirmed_user)
end

Given /^I am logged in$/ do
  @user ||= FactoryGirl.create(:confirmed_user)
  visit root_path(:subdomain => @user.username)
  click_link I18n.t('app.user.login')
  fill_in 'Login', :with => @user.email
  fill_in 'Password', :with => @user.password
  click_button "Log in"
  page.body.should_not include 'Log in'
  page.body.should include "quantified awesome: #{@user.username}"
end

Given /^I have the following stuff:$/ do |table|
  table.hashes.each do |o|
    stuff = FactoryGirl.create(:stuff, :name => o['Name'], :user => @user)
    stuff.home_location = @user.get_location(o['Home location']) unless o['Home location'].blank?
    stuff.location = @user.get_location(o['Current location']) unless o['Current location'].blank?
    stuff.save
  end
end

When /^I go to the context creation page$/ do
  visit new_context_path
end

Then /^I should not have access$/ do
  page.should have_content I18n.t('app.user.login_submit')
end


Given /^I have the following clothing logs:$/ do |table|
  table.hashes.each do |r|
    FactoryGirl.create(:clothing_log, :user => @user, :date => Time.zone.parse(r['Date']), :clothing => Clothing.find_by_name(r['Clothing']))
  end 
end

When /^I go to the clothing page for "([^"]*)"$/ do |arg1|
  visit clothing_path(Clothing.find_by_name(arg1))
end

Then /^I should see that it is active$/ do
  page.should have_content 'active'
end

Then /^I should see that I can donate it$/ do
  page.should have_content 'donate'
end

Then /^I should see that I have worn this with "([^"]*)" before$/ do |arg1|
  within ".previous_matches" do
    page.find ".clothing_#{Clothing.find_by_name(arg1).id}"
  end
end

Then /^I should see that "([^"]*)" (?:is|are) a possible match$/ do |arg1|
  within ".matches" do
    page.find ".clothing_#{Clothing.find_by_name(arg1).id}"
  end
end

Then /^I should not see that "([^"]*)" (?:is|are) a possible match$/ do |arg1|
  within ".matches" do
    page.should_not have_selector ".clothing_#{Clothing.find_by_name(arg1).id}"
  end
end

When /^I create a new piece of clothing$/ do
  visit new_clothing_path
  fill_in 'clothing[name]', :with => 'red shirt'
  fill_in 'clothing[tag_list]', :with => 'top, casual'
  fill_in 'clothing[clothing_type]', :with => 'top'
  fill_in 'clothing[colour]', :with => '#ff0000'
  fill_in 'clothing[notes]', :with => 'From Value Village'
  fill_in 'clothing[cost]', :with => '2.99'
  click_button I18n.t('app.general.save')
end

Then /^the clothing should be mine$/ do
  Clothing.last.user_id.should == @user.id
end

Then /^the clothing should be active$/ do
  Clothing.last.status.should == 'active'
end

When /^I edit the "([^"]*)" clothing item$/ do |a|
  @clothing = Clothing.find_by_name a
  visit edit_clothing_path(@clothing)
end
When /^I edit a piece of clothing$/ do
  @clothing = FactoryGirl.create(:clothing, :user => @user)
  visit edit_clothing_path(@clothing)
end

When /^I tag it as "([^"]*)"$/ do |arg1|
  fill_in 'clothing[tag_list]', :with => arg1
end

When /^I save it$/ do
  click_button I18n.t('app.general.save')
end

When /^I delete it$/ do
  click_link I18n.t('app.general.delete')
end

Then /^the clothing should be tagged "([^"]*)"$/ do |arg1|
  Clothing.last.tag_list.join(', ').should == arg1
end

When /^I delete "([^"]*)"$/ do |arg1|
  visit clothing_path(Clothing.find_by_name(arg1))
  click_button I18n.t('app.general.delete')
end


When /^I go to the clothing tag page for "([^"]*)"$/ do |arg1|
  visit clothing_by_tag_path(arg1)
end

When /^I go to the clothing status page for "([^"]*)"$/ do |arg1|
  visit clothing_by_status_path(arg1)
end

Given /^another user has the following clothing items:$/ do |table|
  # table is a Cucumber::Ast::Table
  @other ||= FactoryGirl.create(:user)
  table.hashes.each do |h|
    c = FactoryGirl.create(:clothing, :user => @other, :name => h['Name'], :status => h['Status'])
    c.tag_list = h['Tags']
    c.save!
  end
end

When /^I switch to the other user's domain$/ do
  @other ||= FactoryGirl.create(:user)
  host! "#{@other.username}.example.com"
  Capybara.app_host = "http://#{@other.username}.example.com"
end

When /^I log in with my e\-mail address$/ do
  visit root_url
  click_link I18n.t('app.user.login')
  @user = FactoryGirl.create(:user)
  fill_in "user[login]", :with => @user.email
  fill_in "user[password]", :with => @user.password
  click_button I18n.t('app.user.login_submit')
end

Then /^I should be logged in$/ do
  page.should_not have_content I18n.t('app.user.login_submit')
  page.should_not have_content I18n.t('app.user.login')

end

When /^I log in with my username$/ do
  visit root_url
  click_link I18n.t('app.user.login')
  @user = FactoryGirl.create(:user)
  fill_in "user[login]", :with => @user.username
  fill_in "user[password]", :with => @user.password
  click_button I18n.t('app.user.login_submit')
end

Given /^another user has the following memories:$/ do |table|
  @other ||= FactoryGirl.create(:user)
  table.hashes.each do |x|
    FactoryGirl.create(:memory, :name => x['Title'], :body => x['Text'], :tag_list => x['Tags'],
            :access => (x['Public'] || 'Yes').downcase == 'no' ? 'private' : 'public', :user => @other)
  end
end

When /^I view a list of memories$/ do
  visit memories_path
end

Then /^I should see "([^"]*)"$/ do |arg1|
  page.should have_content arg1
end

When /^I log out$/ do
  click_link I18n.t('app.user.logout')
end

Then /^I should not see "([^"]*)"$/ do |arg1|
  page.should_not have_content arg1
end

When /^I create a memory with the following information:$/ do |table|
  visit new_memory_path
  table.hashes.each do |x|
    fill_in 'memory[name]', :with => x['Title']
    fill_in 'memory[body]', :with => x['Text']
    fill_in 'memory[tag_list]', :with => x['Tags']
    if (x['Public'] || 'Yes').downcase == 'no'
      choose I18n.t('app.general.private'), :from => 'memory[access]'
    end
    click_button I18n.t('app.general.save')
  end
end

When /^I view the "([^"]*)" memory$/ do |arg1|
  m = Memory.find_by_name(arg1)
  host! "#{m.user.username}.example.com"
  Capybara.app_host = "http://#{m.user.username}.example.com"
  visit memory_path(m)
end

When /^I create a linked memory with the following attributes:$/ do |table|
  click_link I18n.t('app.memory.new_with_link')
  table.hashes.each do |x|
    fill_in 'memory[name]', :with => x['Title']
    fill_in 'memory[body]', :with => x['Text']
    fill_in 'memory[tag_list]', :with => x['Tags']
    if (x['Public'] || 'Yes').downcase == 'no'
      choose I18n.t('app.general.private'), :from => 'memory[access]'
    end
    click_button I18n.t('app.general.save')
  end
end

Then /^I should see "([^"]*)" is a linked memory$/ do |arg1|
  within ".memory_links" do
    page.should have_content arg1
  end
end

When /^I link it with "([^"]*)"$/ do |arg1|
  click_link I18n.t('app.memory.link')
  click_link arg1
end

Given /^I have the following memories:$/ do |table|
  table.hashes.each do |x|
    FactoryGirl.create(:memory, :name => x['Title'], :body => x['Text'], :tag_list => x['Tags'],
            :access => (x['Public'] || 'Yes').downcase == 'no' ? 'private' : 'public', :user => @user)
  end
end

When /^I say it happened differently with the following information:$/ do |table|
  click_link I18n.t('app.memory.my_version')
  table.hashes.each do |x|
    fill_in 'memory[name]', :with => x['Name']
    fill_in 'memory[body]', :with => x['Text']
    fill_in 'memory[tag_list]', :with => x['Tags']
    if (x['Public'] || 'Yes').downcase == 'no'
      choose I18n.t('app.general.private'), :from => 'memory[access]'
    end
    click_button I18n.t('app.general.save')
  end
end

When /^I am on my own subdomain$/ do
  host! "#{@user.username}.example.com"
  Capybara.app_host = "http://#{@user.username}.example.com"
end

When /^I create a record category named "([^"]*)" which is a "([^"]*)"$/ do |arg1, arg2|
  visit new_record_category_path
  fill_in 'record_category[name]', :with => arg1
  select arg2, :from => 'record_category[category_type]'
  click_button I18n.t('app.general.save')
end

When /^I create a record category named "([^"]*)" which is an "([^"]*)" under "([^"]*)"$/ do |arg1, arg2, arg3|
  visit new_record_category_path
  fill_in 'record_category[name]', :with => arg1
  choose arg2, :from => 'record_category[category_type]'
  fill_in 'record_category[parent]', :with => arg3
  click_button I18n.t('app.general.save')
end

When /^I go to my time log$/ do
  visit track_time_path
end

When /^I click on "([^"]*)"$/ do |arg1|
  click_link arg1
end

Then /^I should see that my time has been logged$/ do
  page.body should include I18n.t('time_log.logged')
end
