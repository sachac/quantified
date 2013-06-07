require 'spec_helper'

describe RecordCategory do
  describe '#add_data' do
    context 'when no ancestors' do
      it 'includes the category name' do
        u = FactoryGirl.create(:confirmed_user)
        cat = FactoryGirl.create(:record_category, category_type: 'list', name: 'Parent Category')
        cat.full_name.should == 'Parent Category'
      end
    end
    context 'when has ancestors' do
      it 'includes the parent category names' do
        u = FactoryGirl.create(:confirmed_user)
        cat = FactoryGirl.create(:record_category, category_type: 'list', name: 'Parent Category')
        cat2 = FactoryGirl.create(:record_category, category_type: 'list', name: 'Child Category', parent: cat)
        cat2.full_name.should == 'Parent Category - Child Category'
      end
    end
  end

  describe 'with some records' do
    before(:each) do
      @user = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, category_type: 'activity', user: @user, data: [{'key' => 'note', 'label' => 'Note', 'type' => 'text'}])
      @cat2 = FactoryGirl.create(:record_category, category_type: 'list', user: @user, name: 'Category2')
      @cat2_child = FactoryGirl.create(:record_category, category_type: 'activity', user: @user, parent: @cat2, name: 'Child')
      # 2012-01-02 8:00 cat
      # 2012-01-02 9:00 cat2-child
      # 2012-01-02 10:00 - 2012-01-03 11:00 cat2child
      FactoryGirl.create(:record, record_category: @cat, user: @user, timestamp: Time.zone.local(2012, 1, 2, 8))
      FactoryGirl.create(:record, record_category: @cat2_child, user: @user, timestamp: Time.zone.local(2012, 1, 2, 9), data: {'note' => 'search'}).update_previous
      FactoryGirl.create(:record, record_category: @cat2_child, user: @user, timestamp: Time.zone.local(2012, 1, 2, 10), end_timestamp: Time.zone.local(2012, 1, 3, 11), data: {'note' => '!private'}, manual: true).update_previous
      @options = {records: @user.records, user: @user, zoom: :daily}
    end

    describe '.roll_up_records' do
      context 'when range is specified' do
        it 'limits the records to that range' do
          @options[:range] = Time.zone.local(2012, 1, 2)..Time.zone.local(2012, 1, 3)
          list = RecordCategory.roll_up_records(@options)
          list[:total][:total][Time.zone.local(2012, 1, 2).to_date].should == 16 * 60 * 60
        end
      end
      context 'when parent is specified' do
        it 'limits the records to that branch' do
          @options[:parent] = @cat2
          list = RecordCategory.roll_up_records(@options)
          list[:total][:total].values.sum.should == 26 * 60 * 60
        end
      end
      context 'when displaying a full tree' do 
        it 'displays categories' do
          @options[:tree] = :full
          list = RecordCategory.roll_up_records(@options)
          list[:rows][@cat.id][:total].should == 60 * 60
          list[:rows][@cat2.id][:total].should == 26 * 60 * 60
          list[:rows][@cat2_child.id][:total].should == 26 * 60 * 60
        end
      end
      context 'when displaying a next level tree' do 
        it 'displays categories' do
          @options[:tree] = :next_level
          list = RecordCategory.roll_up_records(@options)
          list[:rows][@cat.id][:total].should == 60 * 60
          list[:rows][@cat2.id][:total].should == 26 * 60 * 60
          list[:rows][@cat2_child.id].size.should == 0
        end
      end
      context 'when displaying a next level tree with a parent' do 
        it 'displays categories' do
          @options[:tree] = :next_level
          @options[:parent] = @cat2
          list = RecordCategory.roll_up_records(@options)
          list[:rows][@cat2_child.id][:total].should == 26 * 60 * 60
        end
      end
      context 'when summarizing by date' do
        it 'uses dates as the key' do
          @options[:key] = :date
          list = RecordCategory.roll_up_records(@options)
          list[:rows][Time.zone.local(2012, 1, 2).to_date][@cat.id].should == 3600
        end
      end
    end
    describe '.summarize' do
      it "summarizes records" do
        list = RecordCategory.summarize(@options)
        list[:total][:total][Time.zone.local(2012, 1, 2).to_date].should == 16 * 60 * 60
      end
    end
    describe '#summarize' do
      context 'when summarizing an activity' do
        it "summarizes records" do
          list = @cat.summarize(@options)
          list[:total][:total][Time.zone.local(2012, 1, 2).to_date].should == 1 * 60 * 60
        end
      end
      context 'when summarizing a list' do
        it "summarizes records" do
          list = @cat2.summarize(@options)
          list[:total][:total].values.sum.should == 26 * 60 * 60
        end
      end
    end
    describe '#tree_records' do
      it "returns all nested records" do
        @cat2.tree_records.size.should == 2
      end
    end
    describe '#category_records' do
      context 'when specifying a range' do
        it "limits records to only those in that range" do
          @cat2_child.category_records(start: Time.zone.local(2012, 1, 2), end: Time.zone.local(2012, 1, 2, 10)).size.should == 1
        end
      end
      context 'when requesting chronological order' do
        it "returns oldest entries first" do
          @cat2_child.category_records(order: 'oldest').first.timestamp.hour.should == 9
        end
      end
      context 'when requesting reverse-chronological order' do
        it "returns newest entries first" do
          @cat2_child.category_records(include_private: true).first.timestamp.hour.should == 10
        end
      end
      context 'when requesting a tree' do
        it "returns child categories' records" do
          @cat2.category_records(include_private: true).first.timestamp.hour.should == 10
        end
      end
      context 'when filtering' do
        it "shows only filtered items" do
          @cat2.category_records(filter_string: 'search').size.should == 1
        end
      end
      context 'when including private' do
        it "includes private entries" do
          @cat2.category_records(include_private: true).size.should == 2
        end
      end
    end
    it "converts to CSV" do
      @cat2_child.to_comma.should == [@cat2_child.id.to_s,
                                      'Child',
                                      'activity',
                                      'Category2 - Child',
                                      '',
                                      @cat2.id.to_s,
                                      @cat2.id.to_s + "." + @cat2_child.id.to_s,
                                      '']
    end
  end

  describe '.find_or_create' do
    context "when category exists" do
      it "returns the existing category" do
        u = FactoryGirl.create(:confirmed_user)
        c = FactoryGirl.create(:record_category, user: u, name: 'Discretionary')
        x = RecordCategory.find_or_create(u, ['Discretionary'])
        x.should == c
      end
    end
    context "when category does not exist" do
      it "creates the category" do
        u = FactoryGirl.create(:confirmed_user)
        x = RecordCategory.find_or_create(u, ['Discretionary'])
        x.name.should == 'Discretionary'
      end
    end
    context "when path does not exist" do
      it "creates path elements along the way" do
        u = FactoryGirl.create(:confirmed_user)
        x = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening'])
        x.name.should == 'Gardening'
        x.parent.name.should == 'Discretionary'
      end
    end
    context "when including an existing category in the path" do
      it "creates path elements along the way" do
        u = FactoryGirl.create(:confirmed_user)
        x = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening'])
        y = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening', 'Backyard'])
        y.parent.should be_list
      end
    end
  end

  describe '#get_color' do
    context 'when a color is specified' do
      it "returns that color" do
        u = FactoryGirl.create(:confirmed_user)
        x = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening'])
        y = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening', 'Backyard'])
        y.color = '0000ff'
        y.save
        y.get_color.should == '0000ff'
      end
    end
    context "when a parent's color is specified" do
      it "returns the parent's color" do
        u = FactoryGirl.create(:confirmed_user)
        x = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening'])
        y = RecordCategory.find_or_create(u, ['Discretionary', 'Gardening', 'Backyard'])
        x.color = '0000ff'
        x.save
        y.reload
        y.parent.reload
        y.get_color.should == '0000ff'
      end
    end
  end
  
  describe '.search' do
    before(:each) do 
      @u = FactoryGirl.create(:confirmed_user)
      @cat = FactoryGirl.create(:record_category, user: @u, category_type: 'list', name: 'Parent Category')
      @activity = FactoryGirl.create(:record_category, user: @u, category_type: 'activity', name: 'Child Category', parent: @cat)
      @record = FactoryGirl.create(:record_category, user: @u, category_type: 'record', name: 'Child Record', parent: @cat)
    end
    context 'when searching for an activity' do
      it "returns the activity" do
        RecordCategory.search(@u, 'Child', activity: true).should == @activity
      end
    end
    context 'when searching for an unambiguous match' do
      it "returns an entry" do
        RecordCategory.search(@u, 'Record').should == @record
      end
    end
    context 'when searching for an ambiguous match' do
      it "returns an entry" do
        RecordCategory.search(@u, 'Child').should == [@activity, @record]
      end
    end
  end

  describe '#child_records' do
    it "includes child categories" do
      cat = FactoryGirl.create(:record_category)
      cat2 = FactoryGirl.create(:record_category, parent: cat, user: cat.user)
      rec = FactoryGirl.create(:record, record_category: cat2, user: cat.user)
      cat.child_records.should == [rec]
    end
  end

  describe '#cumulative_time' do
    before(:each) do 
      @cat = FactoryGirl.create(:record_category)
      @cat2 = FactoryGirl.create(:record_category, parent: @cat, user: @cat.user, category_type: 'activity')
      rec = FactoryGirl.create(:record, record_category: @cat2, user: @cat.user, timestamp: Time.zone.local(2012, 1, 2), end_timestamp: Time.zone.local(2012, 1, 2, 3))
      rec2 = FactoryGirl.create(:record, record_category: @cat2, user: @cat.user, timestamp: Time.zone.local(2012, 1, 3, 1), end_timestamp: Time.zone.local(2012, 1, 3, 2))
    end
    context 'when no range is given' do
      it 'calculates the sum' do 
        @cat.cumulative_time.should == 4 * 60 * 60
      end
    end
    context 'when a range is given and the records fit within it' do 
      it "calculates the sum" do
        @cat.cumulative_time(Time.zone.local(2012, 1, 1)..Time.zone.local(2012, 1, 3)).should == 3 * 60 * 60
      end
    end
    context 'when a range is given and the record starts before it' do 
      it "cuts off the part before the range" do
        @cat.cumulative_time(Time.zone.local(2012, 1, 2, 1)..Time.zone.local(2012, 1, 3)).should == 2 * 60 * 60
      end
    end
    context 'when a range is given and the record starts before it and has no end time' do 
      it "cuts off the part after the range" do
        rec = FactoryGirl.create(:record, record_category: @cat2, user: @cat.user, timestamp: Time.zone.local(2013, 1, 2))
        @cat.cumulative_time(Time.zone.local(2013, 1, 2, 1)..Time.zone.local(2013, 1, 3)).should == 23 * 60 * 60
      end
    end
    context 'when a range is given and the record ends after it' do 
      it "cuts off the part after the range" do
        @cat.cumulative_time(Time.zone.local(2012, 1, 2, 1)..Time.zone.local(2012, 1, 2, 2)).should == 1 * 60 * 60
      end
    end
  end

  context "when an activity" do
    subject { FactoryGirl.create(:record_category, category_type: 'activity') }
    it { should_not be_list }
    it { should be_activity }
    it { should_not be_record }
  end

  context "when a list" do
    subject { FactoryGirl.create(:record_category, category_type: 'list') }
    it { should be_list }
    it { should_not be_activity }
    it { should_not be_record }
  end

  context "when a record" do
    subject { FactoryGirl.create(:record_category, category_type: 'record') }
    it { should_not be_list }
    it { should_not be_activity }
    it { should be_record }
  end

  describe ".as_child_id" do
    it "handles identity" do
      RecordCategory.as_child_id('1.2', '1.2').should == ""
    end
    it "handles direct child" do
      RecordCategory.as_child_id('1.2', '1.2.3').should == '3'
    end
    it "handles descendant" do
      RecordCategory.as_child_id('1.2', '1.2.3.4').should == '3'
    end
    it "handles non-children" do
      RecordCategory.as_child_id('1.2', '1.3.4.5').should be_nil
    end
    it "is not confused by substrings" do
      RecordCategory.as_child_id('1.2', '1.21').should be_nil
    end
  end
end
