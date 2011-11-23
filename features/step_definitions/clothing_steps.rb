Given /^I have the following clothing items:$/ do |table|
  table.hashes.each do |h|
    Factory(:clothing, :user => @user, :name => h['Name'], :status => h['Status'])
  end
end

When /^I go to the clothing index path$/ do
  visit clothing_index_path
end

Then /^I should see the following clothing items:$/ do |table|
  table.raw.each do |r|
    page.should have_content r
  end
end

Then /^I should not see the following clothing items:$/ do |table|
  table.raw.each do |r|
    page.should_not have_content r
  end
end
