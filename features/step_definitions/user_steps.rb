
Then /^display the page$/ do
  puts page.body
end

Then /^display the page text$/ do
  puts page.text
end

When /^I go to the dashboard$/ do
  visit root_path
end

When(/^I go to the privacy page$/) do
  visit privacy_path
end

Then(/^I should see the privacy page$/) do
  page.should have_content 'privacy'
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
  page.should have_content "#{arg1}"
end

Then /^I should see an error$/ do
  page.body.should include 'error'
end

Given /^I am a (?:new )?user$/ do
  @user = FactoryGirl.create(:confirmed_user)
end

Given /^I am logged in|I log in$/ do
  @user = FactoryGirl.create(:confirmed_user)
  visit root_path(:subdomain => @user.username)
  click_link I18n.t('app.user.login')
  within '.login' do
    fill_in 'user[login]', :with => @user.email
    fill_in 'user[password]', :with => @user.password
    click_button "Log in"
  end
  page.body.should_not include 'Log in'
  page.body.should include "#{@user.username}"
end

Then /^I should see a reminder to set my timezone$/ do
  page.body.should include "Set timezone"
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


When /^I save it$/ do
  click_button I18n.t('app.general.save')
end

When /^I delete it$/ do
  unless page.has_link?(I18n.t('app.general.delete'))
    click_link I18n.t('app.general.edit')
  end
  click_link I18n.t('app.general.delete')
end

When /^I log in with my e\-mail address$/ do
  visit root_url
  click_link I18n.t('app.user.login')
  @user = FactoryGirl.create(:confirmed_user)
  within '.login' do
    fill_in "user[login]", :with => @user.email
    fill_in "user[password]", :with => @user.password
    click_button I18n.t('app.user.login_submit')
  end
end

Then /^I should be logged in$/ do
  page.should_not have_content I18n.t('app.user.login_submit')
  page.should_not have_content I18n.t('app.user.login')

end

When /^I log in with my username$/ do
  visit root_url
  click_link I18n.t('app.user.login')
  @user = FactoryGirl.create(:confirmed_user)
  within ".login" do
    fill_in "user[login]", :with => @user.username
    fill_in "user[password]", :with => @user.password
    click_button I18n.t('app.user.login_submit')
  end
end

Given /^the other user has the following memories:$/ do |table|
  table.hashes.each do |x|
    FactoryGirl.create(:memory, name: x['Title'], body: x['Text'], tag_list: x['Tags'],
            access: (x['Public'] || 'Yes').downcase == 'no' ? 'private' : 'public', user: @other)
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
  choose 'record_category_category_type_' + arg2
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

When /^I register$/ do
  visit new_user_session_path
  within ".sign_up" do
    fill_in "user[email]", :with => "test@sachachua.com"
    fill_in "user[password]", :with => "PasswordX"
    fill_in "user[password_confirmation]", :with => "PasswordX"
    click_button I18n.t('user.sign_up')
  end
end

Then /^I should see the thank you page$/ do
  page.body.should include 'Thank you'
end

Given /^there is another user$/ do
  @other = FactoryGirl.create(:confirmed_user, username: 'other')
end

Given /^there is a demo user$/ do
  @demo = FactoryGirl.create(:user, :demo, username: 'demo')
end

Given /^the date is ([\-0-9]+)$/ do |date|
  Timecop.travel(Time.zone.parse(date))
end

When(/^I edit it$/) do
  click_link('Edit')
end

Then(/^the page should contain "(.*?)"$/) do |arg1|
  page.body.should match(arg1)
end

Then(/^the page should not contain "(.*?)"$/) do |arg1|
  page.body.should_not match(arg1)
end


Given(/^I go to the menu$/) do
  visit menu_path
end

When(/^I sign up as a new user$/) do
  visit new_user_path
  within '.sign_up' do
    fill_in 'user[email]', with: 'signup@example.com'
    fill_in 'user[password]', with: 'signup@example.com password'
    fill_in 'user[password_confirmation]', with: 'signup@example.com password'
    click_button('Sign up')
  end
end

When(/^I sign up as a new user when I already have an account$/) do
  u = create(:user)
  visit new_user_path
  fill_in 'user[email]', with: u.email
  click_button('Sign up')
end

When(/^I send feedback$/) do
  visit feedback_path
  fill_in 'email', with: 'test@example.com'
  fill_in 'message', with: 'Feedback message goes here'
  click_button('Send feedback')
end

Then /^the administrator should receive a feedback email$/ do 
  unread_emails_for(ApplicationMailer::ADMIN_ADDRESS).select { |m| m.subject =~ /Feedback/ }.size.should >= 1
end

When(/^I view my dashboard$/) do
  visit root_path
end
