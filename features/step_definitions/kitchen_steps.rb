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
  table.hashes.each do |h|
    create(:grocery_list_item, name: h['Name'], status: h['Status'].downcase, grocery_list: @grocery_list)
  end
end

When(/^I clear all crossed\-off items$/) do
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
Then(/^the current price of "(.*?)" should be (\d+)\.(\d+)$/) do |arg1, arg2, arg3|
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

When(/^I have the following price history:$/) do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |h|
    type = @user.receipt_item_types.find_by(friendly_name: h['Name'])
    if type.nil?
      type = @user.receipt_item_types.create(friendly_name: h['Name'])
    end
    create(:receipt_item, name: h['Name'], receipt_item_type: type, quantity: h['Quantity'], unit_price: h['Unit price'], total: h['Total'], date: h['Date'], user: @user)
  end
end

When(/^I view the grocery item page for "(.*?)"$/) do |arg1|
  item = @grocery_list.grocery_list_items.find_by(name: arg1)
  visit grocery_list_item_path(item)
end

Then(/^I should see that "(.*?)" had the past price of (\d+)\.(\d+)$/) do |arg1, arg2, arg3|
  expect(page.body).to match arg3
end

When(/^the other user accepts the invitation$/) do
  click_link I18n.t('app.user.logout')
  @other = User.find_by(email: @other_user_email)
  expect(@other.invitation_token).to_not be_nil
  @other_password = 'test password'
  puts accept_user_invitation_url(invitation_token: @other.invitation_token)
  visit accept_user_invitation_url(invitation_token: @other.invitation_token)
  puts page.body
  
  @other.reload
end

When(/^the other user logs in$/) do
  click_link I18n.t('app.user.login')
  within '.login' do
    fill_in 'user[login]', :with => @other.email
    fill_in 'user[password]', :with => @other.password
    click_button "Log in"
  end
  page.body.should_not include 'Log in'
end


When(/^I share my grocery list with a non\-existent user$/) do
  visit edit_grocery_list_path(@grocery_list)
  @other_user_email = 'test_new_user@example.com'
  fill_in 'email', with: @other_user_email
  click_button 'Submit'
end

Then(/^I should see that the other user does not exist$/) do
  expect(page.body).to include I18n.t('grocery_lists.user_not_found', email: @other_user_email)
end

Then(/^the other user should see the list in their grocery lists$/) do
  no_access = create(:grocery_list, user: @user)
  visit grocery_lists_path
  expect(page.body).to include grocery_list_path(@grocery_list)
  expect(page.body).to_not include grocery_list_path(no_access)
end

Then(/^the other user should be able to add "(.*?)"$/) do |arg1|
  visit grocery_list_path(@grocery_list)
  fill_in 'quick_add', with: arg1
  click_button I18n.t('general.add')
end

Then(/^the other user should be able to cross off "(.*?)"$/) do |arg1|
  item = @grocery_list.grocery_list_items.find_by_name(arg1)
  visit grocery_list_path(@grocery_list)
  find(".cross_off_#{item.id}").click
end

When(/^I share my list with an existing user$/) do
  @other = create(:user, :confirmed)
  visit edit_grocery_list_path(@grocery_list)
  fill_in 'email', with: @other.email
  click_button 'Submit'
end

Given(/^I remove the other user from the grocery list$/) do
  visit edit_grocery_list_path(@grocery_list)
  click_link ".remove_access_#{@other.id}"
end

Then(/^the other person should not have access to my grocery list$/) do
  expect(GroceryList.lists_for(@other).count).to eq 0
end
