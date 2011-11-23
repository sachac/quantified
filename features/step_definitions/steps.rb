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
  @user = Factory(:user)
end

Given /^I am logged in$/ do
  @user ||= Factory(:user)
  visit root_path
  click_link I18n.t('app.user.login')
  fill_in 'Login', :with => @user.email
  fill_in 'Password', :with => @user.password
  click_button "Log in"
  page.body.should_not include 'Log in'
  page.body.should include "quantified awesome: #{@user.username}"
end

Given /^I have the following stuff:$/ do |table|
  table.hashes.each do |o|
    stuff = Factory(:stuff, :name => o['Name'], :user => @user)
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

