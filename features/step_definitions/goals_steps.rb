
When(/^I define a goal for it$/) do
  click_link I18n.t('goal.set')
end

When(/^I name the goal "(.*?)"$/) do |arg1|
  fill_in 'goal[label]', with: arg1
end

When(/^I set the goal to be (>=) to ([\.0-9]+) hours?$/) do |op, arg1|
  fill_in 'goal[hours]', with: arg1
  select(op, from: 'goal[op]')
end

When(/^I set the goal to be (daily|weekly|today|monthly)$/) do |arg1|
  select(arg1, from: 'goal[period]')
end
