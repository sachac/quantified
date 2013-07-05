require 'spec_helper'
describe Record do
  describe '#data=' do
    it 'handles strings' do
      x = FactoryGirl.create(:record)
      x.data = ActiveSupport::JSON.encode({'note' => 'hello world'})
      x.data['note'].should == 'hello world'
    end
    it 'handles direct setting' do
      x = FactoryGirl.create(:record)
      x.data = {'note' => 'hello world'}
      x.data['note'].should == 'hello world'
    end
  end
  describe '#end_timestamp_must_be_after_start' do
    it "invalidates records" do
      x = FactoryGirl.build(:record, timestamp: Time.zone.now, end_timestamp: Time.zone.now - 1.hour)
      x.should_not be_valid
    end
  end
  describe '.split' do
    context 'when given a record' do
      it "handles same-day events" do
        x = FactoryGirl.create(:record, timestamp: Time.zone.now.midnight + 1.hour, end_timestamp: Time.zone.now.midnight + 2.hours)
        Record.split(x).should == [x]
      end
      it "handles events that cross one midnight boundary" do
        x = FactoryGirl.create(:record, timestamp: Time.zone.now.midnight - 1.hour, end_timestamp: Time.zone.now.midnight + 2.hours)
        split = Record.split(x)
        split[1].timestamp.should == Time.zone.now.midnight - 1.hour
        split[1].end_timestamp.should == Time.zone.now.midnight
        split[0].timestamp.should == Time.zone.now.midnight
        split[0].end_timestamp.should == Time.zone.now.midnight + 2.hours
      end
      it "handles events that cross two midnight boundaries" do
        x = FactoryGirl.create(:record, timestamp: Time.zone.now.midnight - 1.hour - 1.day, end_timestamp: Time.zone.now.midnight + 2.hours)
        split = Record.split(x)
        split[2].timestamp.should == Time.zone.now.midnight - 1.hour - 1.day
        split[2].end_timestamp.should == Time.zone.now.midnight - 1.day
        split[1].timestamp.should == Time.zone.now.midnight - 1.day
        split[1].end_timestamp.should == Time.zone.now.midnight 
        split[0].timestamp.should == Time.zone.now.midnight 
        split[0].end_timestamp.should == Time.zone.now.midnight + 2.hours
      end
    end
    context 'when given an array' do
      it "splits all the elements" do
        x = FactoryGirl.create(:record, timestamp: Time.zone.now.midnight + 1.hour, end_timestamp: Time.zone.now.midnight + 2.hours)
        Record.split([x]).should == [x]
      end
    end
  end
  describe ".split" do
    it "handles records entirely within a day" do
      user = FactoryGirl.create(:confirmed_user)
      record = FactoryGirl.create(:record, :user => user, :timestamp => Time.zone.now.midnight - 1.day + 7.hours, :end_timestamp => Time.zone.now.midnight - 1.day + 10.hours)
      record.split.should == [[record.timestamp, record.end_timestamp, record]]
    end
    it "handles records that cross one date boundary" do
      user = FactoryGirl.create(:confirmed_user)
      record = FactoryGirl.create(:record, :user => user, :timestamp => Time.zone.now.midnight - 1.day + 7.hours, :end_timestamp => Time.zone.now.midnight + 10.hours)
      record.split.should == [[record.timestamp, Time.zone.now.midnight, record], [Time.zone.now.midnight, record.end_timestamp, record]]
    end
    it "handles records that cross two date boundaries" do
      user = FactoryGirl.create(:confirmed_user)
      record = FactoryGirl.create(:record, :user => user, :timestamp => Time.zone.now.midnight - 1.day + 7.hours, :end_timestamp => Time.zone.now.midnight + 1.day + 10.hours)
      record.split.should == [[record.timestamp, Time.zone.now.midnight.in_time_zone, record], 
                              [Time.zone.now.midnight, Time.zone.now.midnight + 1.day, record],
                              [Time.zone.now.midnight + 1.day, record.end_timestamp, record]]
    end
  end
  
  describe '#add_data' do
    context 'when there is no end time but there is a next activity' do
      it "automatically sets the timestamp" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        r1 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 30.minutes)
        r2 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 1.hour)
        r2.end_timestamp.to_s.should == r1.timestamp.to_s
      end
    end
  end
  describe '#update_next' do
    context 'when the next activity has an ending timestamp' do
      it "adjusts the next activity's starting timestamp" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        r1 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 30.minutes, end_timestamp: Time.zone.now - 15.minutes)
        r2 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 1.hour)
        r2.end_timestamp = r2.end_timestamp + 1.minute
        r2.save
        r2.update_next
        r1.reload.timestamp.to_s.should == r2.end_timestamp.to_s
        r1.duration.should == r1.end_timestamp - r1.timestamp
      end
    end
    context 'when the next activity has no ending timestamp' do
      it "adjusts the next activity's starting timestamp" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        r1 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 30.minutes)
        r2 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 1.hour)
        r2.end_timestamp = r2.end_timestamp + 1.minute
        r2.save
        r2.update_next
        r1.reload.timestamp.to_s.should == r2.end_timestamp.to_s
        r1.duration.should be_nil
      end
    end
  end
  describe '#update_previous' do
    it "adjusts the previous activity's ending timestamp" do
      u = FactoryGirl.create(:confirmed_user)
      c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
      r1 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now)
      r2 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now - 1.hour)
      r1.timestamp = r1.timestamp + 1.minute
      r1.save
      r1.update_previous
      r2.reload.end_timestamp.to_s.should == r1.timestamp.to_s
    end
  end
  describe '.recalculate_durations' do
    it "fixes all the durations" do
      u = FactoryGirl.create(:confirmed_user)
      c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
      r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour)
      r1 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 45.minutes)
      r2 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 15.minutes)
      r3 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 30.minutes)
      r3.destroy
      Record.recalculate_durations(u)
      r1.reload.duration.should == 15 * 60
      r2.reload.duration.should == 30 * 60
    end
    context 'when there is a manual entry' do
      it 'leaves the ending timestamp alone' do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour)
        r1 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 45.minutes)
        r2 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 15.minutes)
        r3 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 30.minutes)
        r3.manual = true
        r3.end_timestamp = r3.timestamp + 1.minute
        r3.save
        Record.recalculate_durations(u)
        r3.reload.duration.should == 60
      end
    end
  end
  describe '#private?' do
    it "recognizes private notes" do
      r3 = FactoryGirl.create(:record, data: {'note' => 'this is !private'})
      r3.should be_private
    end
    it "recognizes public notes" do
      r3 = FactoryGirl.create(:record, data: {'note' => 'this is public'})
      r3.should_not be_private
    end
  end
  describe '#current_activity' do
    context 'when this is an activity' do
      it "returns itself" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour)
        r0.current_activity.should == r0
      end
    end
    context "when this is not an activity" do
      it "returns the enclosing activity if there is one that hasn't ended yet" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        c2 = FactoryGirl.create(:record_category, user: u, category_type: 'record')
        r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour)
        r1 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now)
        r1.current_activity.should == r0
      end
      it "returns the enclosing activity if there is one that spans this" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        c2 = FactoryGirl.create(:record_category, user: u, category_type: 'record')
        r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour, end_timestamp: Time.zone.now.yesterday.midnight + 2.hours)
        r1 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now.yesterday.midnight + 90.minutes)
        r1.current_activity.should == r0
      end
      it "does not return an enclosing activity if there isn't one that spans this" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
        c2 = FactoryGirl.create(:record_category, user: u, category_type: 'record')
        r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour, end_timestamp: Time.zone.now.yesterday.midnight + 2.hours)
        r1 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now)
        r1.current_activity.should be_nil
      end
    end
  end

  describe '#current_activity' do
    it "returns all the records contained by this activity" do
      u = FactoryGirl.create(:confirmed_user)
      c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
      c2 = FactoryGirl.create(:record_category, user: u, category_type: 'record')
      r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour, end_timestamp: Time.zone.now.yesterday.midnight + 2.hours)
      r1 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now.yesterday.midnight + 90.minutes)
      r0.during_this.should == [r1]
    end
  end
  
  describe '#context' do
    it "returns the activity's information" do
      u = FactoryGirl.create(:confirmed_user)
      c = FactoryGirl.create(:record_category, user: u, category_type: 'activity')
      c2 = FactoryGirl.create(:record_category, user: u, category_type: 'record')
      r0 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now.yesterday.midnight + 1.hour, end_timestamp: Time.zone.now.yesterday.midnight + 2.hours)
      r1 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now.yesterday.midnight + 90.minutes)
      r2 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now.yesterday.midnight + 89.minutes)
      r3 = FactoryGirl.create(:record, user: u, record_category: c2, timestamp: Time.zone.now.yesterday.midnight + 91.minutes)
      r4 = FactoryGirl.create(:record, user: u, record_category: c, timestamp: Time.zone.now)
      x = r1.context
      x[:current].should == r0
      x[:previous][:entry].should == r2
      x[:previous][:activity].should == r0
      x[:next][:entry].should == r3
      x[:next][:activity].should == r4
    end
  end

  describe '.choose_zoom_level' do
    it 'suggests daily if within two weeks' do
      Record.choose_zoom_level(Date.new(2013, 1, 1)..Date.new(2013, 1, 14)).should == :daily
    end
    it 'suggests weekly if within 8 weeks' do
      Record.choose_zoom_level(Date.new(2013, 1, 1)..Date.new(2013, 2, 1)).should == :weekly
    end
    it 'suggests monthly if longer' do
      Record.choose_zoom_level(Date.new(2013, 1, 1)..Date.new(2013, 12, 30)).should == :monthly
    end
  end

  describe '.get_zoom_key' do
    it 'gets the day' do
      u = FactoryGirl.create(:confirmed_user)
      Record.get_zoom_key(u, :daily, Time.zone.local(2013, 1, 2, 3, 4)).to_date.should == Time.zone.local(2013, 1, 2).to_date
    end
    it 'gets the end of the week' do
      u = FactoryGirl.create(:confirmed_user)
      Record.get_zoom_key(u, :weekly, Time.zone.local(2013, 1, 2, 3, 4)).to_date.should == Time.zone.local(2013, 1, 4).to_date
    end
    it 'gets the start of the month' do
      u = FactoryGirl.create(:confirmed_user)
      Record.get_zoom_key(u, :monthly, Time.zone.local(2013, 1, 2, 3, 4)).to_date.should == Time.zone.local(2013, 1, 1).to_date
    end
    it 'gets the start of the year' do
      u = FactoryGirl.create(:confirmed_user)
      Record.get_zoom_key(u, :yearly, Time.zone.local(2013, 2, 2, 3, 4)).to_date.should == Time.zone.local(2013, 1, 1).to_date
    end
  end

  describe '#get_zoom_key' do
    it 'gets the day' do
      u = FactoryGirl.create(:confirmed_user)
      f = FactoryGirl.create(:record, user: u, timestamp: Time.zone.local(2013, 1, 2, 3, 4))
      f.get_zoom_key(:daily).to_date.should == Time.zone.local(2013, 1, 2).to_date
    end
  end

  describe '.refresh_from_tap_log' do
    it "loads the information" do
      file = File.new(Rails.root.join('spec/fixtures/files/sample-tap-log.csv'))
      u = FactoryGirl.create(:confirmed_user)
      Record.refresh_from_tap_log(u, file)
      u.records.size.should == 2
      u.records[0].record_category.full_name.should == 'Personal - Routines'
      u.records[1].record_category.full_name.should == 'Discretionary - Gardening'
    end
    it "handles duplicate information" do
      file = File.new(Rails.root.join('spec/fixtures/files/sample-tap-log.csv'))
      u = FactoryGirl.create(:confirmed_user)
      Record.refresh_from_tap_log(u, file)
      Record.refresh_from_tap_log(u, file)
      u.records.size.should == 2
    end
  end

  describe ".guess_time" do
    it "leaves no-time entries alone" do
      o = Record.guess_time("hello")
      o[0].should == "hello"
      o[1].should be_nil
    end
    it "deals with nil" do
      o = Record.guess_time(nil)
      o[0].should be_nil
      o[1].should be_nil
    end
    it "recognizes hh:mm string" do
      o = Record.guess_time("8:00 test")
      o[0].should == "test"
      o[1].hour.should == 8
    end
    it "recognizes string hh:mm" do
      o = Record.guess_time("test 8:00")
      o[0].should == "test"
      o[1].hour.should == 8
    end
    it "recognizes -30min" do
      o = Record.guess_time("test 8:00 -30min")
      o[0].should == "test"
      o[1].hour.should == 7
      o[1].min.should == 30
    end
    it "recognizes -1h" do
      o = Record.guess_time("test 8:00 -1h")
      o[0].should == "test"
      o[1].hour.should == 7
      o[1].min.should == 00
    end
    it "recognizes +5m" do
      x = Time.zone.now + 5.minutes
      o = Record.guess_time("test +5m")
      o[0].should == "test"
      o[1].hour.should == x.hour
      o[1].min.should == x.min
    end
    it "recognizes +1h" do
      x = Time.zone.now + 1.hour
      o = Record.guess_time("test +1h")
      o[0].should == "test"
      o[1].hour.should == x.hour
      o[1].min.should == x.min
    end
    it "recognizes m/d" do
      o = Record.guess_time("test 8:00 1/1")
      o[0].should == "test"
      o[1].month.should == 1
      o[1].day.should == 1
    end
    it "recognizes m/d beyond today" do
      o = Record.guess_time("test 12/31")
      o[1].year.should == Time.zone.now.year - 1
    end
    it "recognizes hh:mm hh:mm" do
      o = Record.guess_time("test 8:00 9:00")
      o[0].should == "test"
      o[1].hour.should == 8
      o[1].min.should == 0
      o[2].hour.should == 9
      o[2].min.should == 0
    end
    it "recognizes -3h -2h" do
      x = Time.zone.now
      o = Record.guess_time("test -3h -2h")
      o[0].should == "test"
      o[1].hour.should == x.hour - 3
      o[2].hour.should == x.hour - 2
    end
    it "recognizes -3h -20min" do
      x = Time.zone.now
      offset = x - 20.minutes
      o = Record.guess_time("test -3h -20min")
      o[0].should == "test"
      o[1].hour.should == x.hour - 3
      o[2].hour.should == offset.hour
      o[2].min.should == offset.min
    end
    it "bases it on the date" do
      o = Record.guess_time("test 8:00", date: Time.zone.local(2013, 1, 2))
      o[0].should == "test"
      o[1].hour.should == 8
      o[1].min.should == 0
      o[1].month.should == 1
      o[1].day.should == 2
      o[1].year.should == 2013
    end
  end

  describe '#confirm_batch' do
    it "parses lines" do 
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user, :name => 'ABCX', :category_type => 'activity')
      @cat2 = FactoryGirl.create(:record_category, :user => @user, :name => 'XYZ', :category_type => 'activity')
      ending_rec = FactoryGirl.create(:record, user: @user, record_category: @cat, timestamp: Time.zone.now.tomorrow.midnight)
      lines = <<END
7:30 ABC
8:30 XYZ
9:30 X
10:00 J
END
      out = Record.confirm_batch(@user, lines)
      out.length.should == 4
      out[0][:timestamp].hour.should == 7
      out[0][:timestamp].min.should == 30
      out[0][:text].should == "7:30 ABC"
      out[0][:category].should == @cat
      out[1][:timestamp].hour.should == 8
      out[1][:timestamp].min.should == 30
      out[1][:category].should == @cat2
      out[2][:category].length.should == 2
      out[3][:category].should be_nil
      out[3][:end_timestamp].should == ending_rec.timestamp
    end
  end

  describe '#create_batch' do
    it "creates unambiguous records" do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user, :name => 'ABCX')
      @cat2 = FactoryGirl.create(:record_category, :user => @user, :name => 'XYZ')
      lines = <<END
7:30 ABC
8:30 XYZ
9:30 X
10:00 J
END
      out = Record.confirm_batch(@user, lines)
      Record.create_batch(@user, out)
      @user.records.length.should == 2
    end
    it 'sets the end if specified' do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user, :name => 'ABCX', :category_type => 'activity')
      @cat2 = FactoryGirl.create(:record_category, :user => @user, :name => 'XYZ', :category_type => 'activity')
      prev_rec = FactoryGirl.create(:record, user: @user, record_category: @cat, timestamp: Time.zone.now.midnight)
      next_rec = FactoryGirl.create(:record, user: @user, record_category: @cat, timestamp: Time.zone.now.tomorrow.midnight)

      lines = <<END
7:30 ABC
8:30 9:00 XYZ
9:30 X
10:00 J
END
      out = Record.confirm_batch(@user, lines)
      Record.create_batch(@user, out, set_end: true)
      prev_rec.reload.end_timestamp.hour.should == 7
      next_rec.reload.timestamp.hour.should == 9
    end
  end

  describe '.parse' do
    before(:each) do 
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, user: @user, name: 'ABC', category_type: 'activity', data: [{'key' => 'notes', 'label' => 'Notes', 'type' => 'end'}])
    end
    context 'when the category is specified' do
      it "gets the category" do
        x = Record.parse(@user, category: '8:00 ABC')
        x.record_category.should == @cat
        x.timestamp.hour.should == 8
      end
      it "deals with ambiguity" do
        cat2 = FactoryGirl.create(:record_category, user: @user, name: 'ABCY', category_type: 'activity', data: [{'key' => 'notes', 'label' => 'Notes', 'type' => 'end'}])
        x = Record.parse(@user, category: '8:00 ABC')
        x.should == [@cat, cat2]
      end
    end
    context 'when quick notes are specified' do
      it "saves the note" do
        x = Record.parse(@user, category: '8:00 ABC | Foo')
        x.record_category.should == @cat
        x.timestamp.hour.should == 8
        x.data['notes'].should == 'Foo'
      end
    end
    context 'when the category ID is specified' do
      it "uses that ID" do
        x = Record.parse(@user, category_id: @cat.id, category: '8:00')
        x.record_category.should == @cat
        x.timestamp.hour.should == 8
      end
    end
    context 'when the timestamp is specified' do
      it "uses that timestamp" do
        x = Record.parse(@user, category_id: @cat.id, timestamp: Time.zone.local(2013, 1, 2, 8, 0))
        x.record_category.should == @cat
        x.timestamp.hour.should == 8
        x.timestamp.day.should == 2
        x.timestamp.month.should == 1
        x.timestamp.year.should == 2013
      end
      it "parses that timestamp" do
        x = Record.parse(@user, category_id: @cat.id, timestamp: Time.zone.local(2013, 1, 2, 8, 0).to_s)
        x.record_category.should == @cat
        x.timestamp.hour.should == 8
        x.timestamp.day.should == 2
        x.timestamp.month.should == 1
        x.timestamp.year.should == 2013
      end
    end
  end
  describe '.get_records' do
    before(:each) do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, category_type: 'activity', user: @user, data: [{'key' => 'note', 'label' => 'Note', 'type' => 'text'}])
      # 2012-01-02 8:00
      FactoryGirl.create(:record, record_category: @cat, user: @user, timestamp: Time.zone.local(2012, 1, 2, 8))
      # 2012-01-02 9:00
      FactoryGirl.create(:record, record_category: @cat, user: @user, timestamp: Time.zone.local(2012, 1, 2, 9), data: {'note' => 'search'})
      # 2012-01-03 10:00 private
      FactoryGirl.create(:record, record_category: @cat, user: @user, timestamp: Time.zone.local(2012, 1, 2, 10), data: {'note' => 'this is !private'})
    end
    it 'returns public records in chronological order if requested' do
      Record.get_records(@user, order: 'oldest')[0].timestamp.hour.should == 8
    end
    it 'returns public records in reverse chronological order' do
      Record.get_records(@user)[0].timestamp.hour.should == 9
    end
    it 'filters by range' do
      list = Record.get_records(@user, 
                                start: Time.zone.local(2012, 1, 2, 8, 30),
                                end: Time.zone.local(2012, 1, 2, 9, 30))
      list.size.should == 1
    end
    it 'filters by string' do
      list = Record.get_records(@user, filter_string: 'search')
      list.size.should == 1
      list[0].timestamp.hour.should == 9
    end
    it 'returns private records if requested' do
      list = Record.get_records(@user, include_private: true)
      list.size.should == 3
    end
  end
  it 'converts to CSV' do 
    user = FactoryGirl.create(:confirmed_user)
    parent_cat = FactoryGirl.create(:record_category, category_type: 'list', name: 'ABC', user: user)
    cat = FactoryGirl.create(:record_category, category_type: 'activity', user: user, data: [{'key' => 'note', 'label' => 'Note', 'type' => 'text'}], name: 'XYZ', parent: parent_cat)
    # 2012-01-02 8:00
    rec = FactoryGirl.create(:record, record_category: cat, user: user, timestamp: Time.zone.local(2012, 2, 2, 8), end_timestamp: Time.zone.local(2012, 2, 2, 9), source_name: 'ruby', source_id: 1, data: {'note' => 'stuff'})
    rec.to_comma.should == ['February 02, 2012 08:00',
                            'February 02, 2012 09:00',
                            'ABC - XYZ',
                            cat.id.to_s,
                            'activity',
                            '3600',
                            'ruby',
                            '1',
                            "{\"note\":\"stuff\"}",
                            "2012-02-02", # day
                            "2012-01-28", # beginning of week
                            "2012-02-01", # beginning of month,
                            "2012-01-01"
                            ]
  end
  describe '#beginning_of_week' do
    rec = FactoryGirl.create(:record, timestamp: Time.zone.local(2012, 2, 2, 8), end_timestamp: Time.zone.local(2012, 2, 2, 9), source_name: 'ruby', source_id: 1, data: {'note' => 'stuff'})
    rec.beginning_of_week.to_date.should == Time.zone.local(2012, 1, 28).to_date
  end
  describe '#prepare_graph' do
    it "splits by date" do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, :user => @user)
      @cat2 = FactoryGirl.create(:record_category, :user => @user)
      FactoryGirl.create(:record, :user => @user, :timestamp => Time.zone.now.midnight - 2.hours, 
                         :end_timestamp => Time.zone.now.midnight + 1.hour, :record_category => @cat) 
      @records = @user.records
      range = (Time.zone.now.to_date - 1.day)..(Time.zone.now.to_date + 1.day)
      list = Record.prepare_graph(range, @records)
      (list[0][0][1] - list[0][0][0]).should == 2.hours
      (list[1][0][1] - list[1][0][0]).should == 1.hour
    end
  end
end
