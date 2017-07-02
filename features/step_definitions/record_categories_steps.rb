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

When(/^I create a record category named "([^"]*)" which is an "([^"]*)" under "([^"]*)"$/)do |arg1, arg2, arg3|
  visit new_record_category_path
  fill_in 'record_category[name]', :with => arg1
  choose "record_category_category_type_#{arg2}"
  p = RecordCategory.find_by_name(arg3)
  select arg3, from: 'record_category[parent_id]'
  click_button I18n.t('app.general.save')
end

When(/^I rename the keys for a category with existing data/) do
  @cat = create(:record_category, user: @user, name: 'Test', data: [{'key' => 'foo', 'label' => 'Bar', 'type' => 'string'}])
  @cat2 = create(:record_category, user: @user, name: 'Another Test', data: [{'key' => 'foo', 'label' => 'Bar', 'type' => 'string'}])
  d1 = create(:record, user: @user, record_category_id: @cat.id, data: {'foo' => 'ABC'})
  d2 = create(:record, user: @user, record_category_id: @cat2.id, data: {'foo' => 'DEF'})
  visit edit_record_category_path(@cat)
  find(:css, 'tr[@data-key="foo"]').fill_in('record_category[data][][key]', with: 'newfoo')
  click_button I18n.t('app.general.save')
end

Then(/^the records should be updated with the same keys/) do
  @cat2.records.first.data['foo'].should eq 'DEF'
  @cat.records.first.data['newfoo'].should eq 'ABC'
end

When(/^I delete the keys for a category$/) do
  @cat = create(:record_category, user: @user, name: 'Test', data: [{'key' => 'foo', 'label' => 'Foo', 'type' => 'string'}, {'key' => 'bar', 'label' => 'Bar', 'type' => 'string'}])
  visit edit_record_category_path(@cat)
  find(:css, 'tr[@data-key="foo"]').fill_in('record_category[data][][key]', with: '')
  click_button I18n.t('app.general.save')
end

Then(/^the category fields should be updated$/) do
  @cat = @cat.reload
  @cat.data.length.should eq 1
  @cat.data[0]['key'].should eq 'bar'
end

Given(/^I have the following categories:$/) do |table|
   # Convert all headers to lower case symbol
  table.map_headers! {|header| header.downcase.to_sym }
  table.hashes.each do |x|
    parent = nil
    if x[:parent] 
      parent = @user.record_categories.find_by(full_name: x[:parent])
    end
    RecordCategory.create(user: @user, name: x[:name], category_type: x[:type], color: x[:color], parent: parent)
  end
end

When(/^I batch\-edit categories$/) do
  visit tree_record_categories_path
end

When(/^I change the name of "(.*?)" to "(.*?)"$/) do |arg1, arg2|
  cat = @user.record_categories.find_by(full_name: arg1)
  fill_in "cat[#{cat.id}][name]", with: arg2
  first('input[name="commit"]').click
end
