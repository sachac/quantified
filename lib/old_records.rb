
oldest = User.first.records.minimum('timestamp')
u = User.first
User.first.records.where(:source => 'migrate').delete_all
if oldest
  recs = TimeRecord.where('start_time < ?', oldest)
  path = nil
  recs.each do |r|
    # Get the category
    case r.name
    when 'A - Sleep'
      path = ['Sleep']
    when 'A - Work'
      path = ['Work', 'Other']
    when 'D - Break'
      path = ['Discretionary', 'Break']
    when 'D - Delegating'
      path = ['Discretionary', 'Delegating']
    when 'D - Drawing'
      path = ['Discretionary', 'Drawing']
    when 'D - Driving'
      path = ['Discretionary', 'Learning', 'Driving']
    when 'D - Electronics'
      path = ['Discretionary', 'Electronics']
    when 'D - Family'
      path = ['Discretionary', 'Social']
    when 'D - Finances'
      path = ['Personal', 'Planning']
    when 'D - Gardening'
      path = ['Discretionary', 'Gardening']
    when 'D - Harry Potter'
      path = ['Discretionary', 'Play', 'LEGO Harry Potter']
    when 'D - Latin'
      path = ['Discretionary', 'Learning', 'Latin']
    when 'D - Learning'
      path = ['Discretionary', 'Learning']
    when 'D - Other'
      path = ['Discretionary', 'Other']
    when 'D - Personal'
      path = ['Discretionary', 'Other']
    when 'D - Piano'
      path = ['Discretionary', 'Learning', 'Piano']
    when 'D - Quantified Awesome'
      path = ['Discretionary', 'Quantified Awesome']
    when 'D - Read'
      path = ['Discretionary', 'Read']
    when 'D - Reading'
      path = ['Discretionary', 'Read']
    when 'D - Sewing'
      path = ['Discretionary', 'Sew']
    when 'D - Shopping'
      path = ['Discretionary', 'Shop']
    when 'D - Social'
      path = ['Discretionary', 'Social']
    when 'D - Travel'
      path = ['Discretionary', 'Travel']
    when 'D - Volunteering'
      path = ['Discretionary', 'Volunteer']
    when 'D - Writing'
      path = ['Discretionary', 'Writing']
    when 'P - Drink'
      path = ['Personal', 'Drink']
    when 'P - Eat'
      path = ['Personal', 'Eat']
    when 'P - Eating'
      path = ['Personal', 'Eat']
    when 'P - Exercise'
      path = ['Personal', 'Exercise']
    when 'P - Plan'
      path = ['Personal', 'Plan']
    when 'P - Planning'
      path = ['Personal', 'Plan']
    when 'P - Prep'
      path = ['Personal', 'Other']
    when 'P - Routines'
      path = ['Personal', 'Routines']
    when 'P - Walk'
      path = ['Personal', 'Walk', 'Other']
    when 'UW - Cook'
      path = ['Unpaid work', 'Cook']
    when 'UW - Cooking'
      path = ['Unpaid work', 'Cook']
    when 'UW - Laundry'
      path = ['Unpaid work', 'Laundry']
    when 'UW - Other'
      path = ['Unpaid work', 'Other']
    when 'UW - Other travel'
      path = ['Unpaid work', 'Other travel']
    when 'UW - Outsourceable'
      path = ['Unpaid work', 'Outsourceable']
    when 'UW - Subway'
      path = ['Unpaid work', 'Subway']
    when 'UW - Tidy up'
      path = ['Unpaid work', 'Tidy up']
    when 'UW - Tidying'
      path = ['Unpaid work', 'Tidy up']
    when 'UW - Travel'
      path = ['Unpaid work', 'Travel']
    when 'UW - Wait'
      path = ['Unpaid work', 'Wait']
    when 'Work'
      path = ['Work', 'Other']
    when 'Work - MBRT'
      path = ['Work', 'M']
    when 'Work - Presentation'
      path = ['Work', 'Presentation']
    when 'Work - TCF'
      path = ['Work', 'T']
    when 'Work - Unified Desktop'
      path = ['Work', 'U']
    when 'Work - ccab'
      path = ['Work', 'C']
    when 'Work - infoprint'
      path = ['Work', 'I']
    end
    if path
      cat = RecordCategory.find_or_create(u, path)
      cat.update_attributes(:category_type => 'activity') unless cat.activity?
      new = u.records.create(:source => 'migrate', :source_id => r.id, :timestamp => r.start_time, :end_timestamp => r.end_time, :duration => r.end_time - r.start_time, :record_category => cat)
    end
  end
end
#
