When(/^I go to the clothing logs matches page$/) do
  visit matches_clothing_logs_path
end

When(/^I go to the clothing log page for "(.*?)" on ([\-0-9]+)$/) do |arg1, arg2|
  clothing = @user.clothing.find_by_name(arg1)
  log = @user.clothing_logs.where(clothing_id: clothing.id, date: Time.zone.parse(arg2).to_date..(Time.zone.parse(arg2).to_date + 1.day)).first
  visit clothing_log_path(log)
end

When(/^I create a new clothing log entry for "(.*?)" on "(.*?)"$/) do |name, date|
  visit new_clothing_log_path
  select(name, from: 'clothing_log[clothing_id]')
  fill_in('Date', with: date)
  click_button('Save')
end

When(/^I change the clothing log entry to "(.*?)"$/) do |name|
  select(name, from: 'clothing_log[clothing_id]')
  click_button('Save')
end

When(/^I go to the clothing logs by date for (.*?)$/) do |arg|
  visit clothing_logs_by_date_path(arg)
end
