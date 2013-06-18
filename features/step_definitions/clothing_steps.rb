Given /^I have the following clothing items:?$/ do |table|
  table.hashes.each do |h|
    c = FactoryGirl.create(:clothing, :user => @user, :name => h['Name'], :status => h['Status'])
    c.tag_list = h['Tags']
    c.save!
  end
end

When /^I go to the clothing index path$/ do
  visit clothing_index_path
end

Then /^I should see the following clothing items:$/ do |table|
  table.raw.each do |r|
    page.should have_content r[0]
  end
end

Then /^I should not see the following clothing items:$/ do |table|
  table.raw.each do |r|
    page.should_not have_content r[0]
  end
end

Given /^I have the following clothing logs:$/ do |table|
  table.hashes.each do |r|
    c = Clothing.find_by_name(r['Clothing']) || create(:clothing, user: @user, name: r['Clothing'], clothing_type: r['Type'])
    FactoryGirl.create(:clothing_log, user: @user, date: Time.zone.parse(r['Date']), clothing: c)
  end 
end

When /^I go to the clothing logs page$/ do
  visit clothing_logs_path
end

When /^I go to the clothing logs page for "([^"]*)"$/ do |arg1|
  visit clothing_logs_clothing_path(Clothing.find_by_name(arg1))
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

Given /^the other user has the following clothing items:$/ do |table|
  table.hashes.each do |h|
    c = FactoryGirl.create(:clothing, user: @other, name: h['Name'], status: h['Status'])
    c.tag_list = h['Tags']
    c.save!
  end
end



