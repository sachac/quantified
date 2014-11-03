
When(/^I define a goal for it$/) do
  click_link I18n.t('goal.set')
end

When(/^I name the goal "(.*?)"$/) do |arg1|
  fill_in 'goal[label]', with: arg1
end

When(/^I set the goal to be (>=) (to )?([\.0-9]+) hours?$/) do |op, ignore, arg1|
  choose 'expression_type_direct'
  select(op, from: 'direct_op')
  fill_in 'direct_target', with: arg1
end

When(/^I set the goal to be (daily|weekly|today|monthly)$/) do |arg1|
  value = case arg1
         when 'daily'
           'Past 24 hours'
         when 'weekly'
           'This week'
         when 'today'
           'Today'
         when 'monthly'
           'This month'
         end
  select(value, from: 'goal[period]')
end
