When /^I define the following rules:$/ do |table|
  fill_in "Rules", :with => table.raw.map { |x| x[0] }.join("\n")
end

When /^I save the context$/ do
  click_button "Save"
end

Then /^the context should exist$/ do
  @context.should_not == nil
end

When /^I start the context$/ do
  visit context_path(@context)
end

Then /^the following things should be reported as out of place:$/ do |table|
  within ".out_of_place" do |scope|
    table1.hashes.each do |row|
      scope.should include row['Name']
    end
  end
end

When /^I mark "([^"]*)" as moved to "([^"]*)"$/ do |arg1, arg2|
  stuff = @user.stuff.find_by_name(arg1)
  within ".stuff_#{stuff.id}" do |scope|
    scope.click_link arg2
  end
end

When /^the following things should be reported as in place:$/ do |table|
  within ".in_place" do |scope|
    table1.raw.each do |row|
      scope.should include row[0]
    end
  end
end

When /^I mark all as done$/ do
  click_link "Complete"
end

Then /^nothing should be reported as out of place$/ do
  page.body.should_not include? " => "
end

Given /^I am a user$/ do
  @user = Factory(:user)
end

Given /^I am logged in$/ do
  visit root_path
  fill_in 'Login', :with => @user.email
  fill_in 'Password', :with => @user.password
  click_button "Log in"
  page.body.should_not include 'Log in'
end

Given /^I have the following stuff:$/ do |table|
  puts @user.class
  table.hashes.each do |o|
    Factory(:stuff, :name => o['Name'], :user => @user)
  end
end

When /^I create a context called "([^"]*)"$/ do |arg1|
  puts page.body
  click_link "Contexts"
  click_link "Create context"
  fill_in "Name", :with => arg1
end

