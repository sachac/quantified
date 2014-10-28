Given(/^I have a grocery list named "(.*?)"$/) do |arg1|
  @grocery_list = FactoryGirl.create(:grocery_list, user: @user, name: 'Home')
end

When(/^I add "(.*?)" to our grocery list$/) do |arg1|
  visit grocery_list_path(@grocery_list)
  fill_in 'quick_add', :with => arg1
  click_button I18n.t('general.add')
end

When(/^I look at our grocery list$/) do
  visit grocery_list_path(@grocery_list)
end

When(/^I set "(.*?)" to belong to "(.*?)"$/) do |arg1, arg2|
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  visit edit_grocery_list_item_path(item)
  fill_in 'grocery_list_item[category]', with: arg2
  click_button I18n.t('general.save')
end

Then(/^I should see "(.*?)" under "(.*?)"$/) do |arg1, arg2|
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  visit grocery_list_path(@grocery_list)
  expect(page.find("tr#item_#{item.id}").text).to match arg2
  expect(item.category).to eq arg2
end

Given(/^I have "(.*?)" on our grocery list$/) do |arg1|
  @grocery_list.grocery_list_items.create(name: arg1)
end

When(/^I cross "(.*?)" off$/) do |arg1|
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  visit grocery_list_path(@grocery_list)
  find(".cross_off_#{item.id}").click
end

Then(/^"(.*?)" should be crossed off$/) do |arg1|
  visit grocery_list_path(@grocery_list)
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  expect(page.find("tr.done#item_#{item.id}")).to_not be_nil
end

When(/^I restore "(.*?)"$/) do |arg1|
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  visit grocery_list_path(@grocery_list)
  find(".restore_#{item.id}").click
end

Then(/^I should have "(.*?)" on our grocery list$/) do |arg1|
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  visit grocery_list_path(@grocery_list)
  expect(page.find("tr#item_#{item.id}")).to_not be_nil
  expect(page).to have_no_selector("tr.done#item_#{item.id}")
end

Given(/^I have a grocery list like:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

When(/^I clear all crosse\-off items$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should not see "(.*?)" on my grocery list$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see "(.*?)" on my grocery list$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^our grocery list should say I need (\d+) "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given(/^the following grocery list categories:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

When(/^I configure "(.*?)" to be first$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the grocery list categories should be:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

When(/^I set the price of "(.*?)" to (\d+)\.(\d+)$/) do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then(/^"(.*?)" should have the price of (\d+)\.(\d+)$/) do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

When(/^I set the price of "(.*?)" to (\d+)\.(\d+) on (\d+)\-(\d+)\-(\d+)$/) do |arg1, arg2, arg3, arg4, arg5, arg6|
  pending # express the regexp above with the code you wish you had
end

Then(/^the current price of "(.*?)" should be (\d+)\.(\d+)$/) do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then(/^"(.*?)" should have the past price of (\d+)\.(\d+) on (\d+)\-(\d+)\-(\d+)$/) do |arg1, arg2, arg3, arg4, arg5, arg6|
  pending # express the regexp above with the code you wish you had
end

When(/^"(.*?)" indicates an intent to pick up "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that "(.*?)" are taken$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

When(/^"(.*?)" clears the intent to pick up "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that "(.*?)" are free to pick up$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

When(/^"(.*?)" sends me a message$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see that message$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^"(.*?)" requests to meet at the counters$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see a request to meet at the counters$/) do
  pending # express the regexp above with the code you wish you had
end

