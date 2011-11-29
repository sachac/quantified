When /^I define the following rules:$/ do |table|
  fill_in "Rules", :with => table.raw.map { |x| x[0] }.join("\n")
end

When /^I save the context$/ do
  click_button "Save"
end

Then /^the context should exist$/ do
  @context = @user.contexts.last
  @context.should_not == nil
end

When /^I start the context$/ do
  visit start_context_path(@context)
end

Then /^the following things should be reported as out of place:$/ do |table|
  table.hashes.each do |row|
    page.body.should have_selector('.out_of_place .stuff_' + Stuff.find_by_name(row['Name']).id.to_s)
  end
end

When /^I mark "([^"]*)" as moved to "([^"]*)"$/ do |arg1, arg2|
  stuff = @user.stuff.find_by_name(arg1)
  within ".stuff_#{stuff.id}" do
    click_link arg2
  end
end

When /^the following things should be reported as in place:$/ do |table|
  table.raw.each do |row|
    page.body.should have_selector('.stuff_in_place .stuff_' + Stuff.find_by_name(row[0]).id.to_s)
  end
end

When /^I mark all as done$/ do
  click_link "Complete"
end

Then /^nothing should be reported as out of place$/ do
  page.body.should_not include "out_of_place"
end

When /^I create a context called "([^"]*)"$/ do |arg1|
  visit new_context_path
  fill_in 'context[name]', :with => arg1
end

