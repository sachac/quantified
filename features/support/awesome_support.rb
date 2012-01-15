Before do
  host! "example.com"
  Capybara.app_host = "http://example.com"
end


When /^I register$/ do
  visit new_user_session_path
  within ".sign_up" do
    fill_in "user[email]", :with => "test@sachachua.com"
    click_button I18n.t('user.sign_up')
  end
end

Then /^I should see the thank you page$/ do
  response.body.should include 'Thank you!'
end

Given /^I am a new user$/ do
  @user = Factory(:user)
end

Given /^I log in$/ do
  sign_in @user
end

Then /^I should see a reminder to set my timezone$/ do
  response.body should have "Set timezone"
end

