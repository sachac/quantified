Given(/^I have a record category named "(.*?)"$/) do |arg1|
  create(:record_category, user: @user, name: arg1)
end


When(/^I view the record category named "(.*?)"$/) do |arg1|
  c = @user.record_categories.find_by_name(arg1)
  visit record_category_path(c)
end

When(/^I go to my record categories$/) do
  visit record_categories_path
end

When /^I create a record category named "([^"]*)" which is an "([^"]*)" under "([^"]*)"$/ do |arg1, arg2, arg3|
  visit new_record_category_path
  fill_in 'record_category[name]', :with => arg1
  choose "record_category_category_type_#{arg2}"
  p = RecordCategory.find_by_name(arg3)
  select arg3, from: 'record_category[parent_id]'
  click_button I18n.t('app.general.save')
end

