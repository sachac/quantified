# TIME

When /^I look at my time use for the past (\d+) days?$/ do |arg1|
  @start_time = Date.today - arg1.to_i.days
  @end_time = Date.today - 1.day
  @log = TimeTrackerLog.new
  @entries = @log.entries(@start_time, @end_time)
  @summary = @log.summarize(@start_time, @end_time)
end

Then /^I should have time data$/ do
  assert @entries != nil
  assert @entries.size > 0
end

Then /^I should have worked between (\d+) and (\d+) hours$/ do |min, max|
  assert_operator @summary['A - Work'] / 1.hour, :>=, min.to_f
  assert_operator @summary['A - Work'] / 1.hour, :<=, max.to_f
end

Then /^I should have slept between (\d+) and (\d+) hours a day$/ do |min, max|
  average = @summary['A - Sleep'] * 1.0 / (1.hour * (@end_time - @start_time))
  assert_operator average, :>=, min.to_f
  assert_operator average, :<=, max.to_f
end

# LIBRARY

When /^I check our library items$/ do
  nil # Actually stored in database, so we don't need anything here. This is more for semantics
end

Then /^there should be no items that are overdue$/ do
  assert_equal 0, LibraryItem.where('status = ? AND due < ?', 'due', Date.today).size
end

