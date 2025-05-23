require 'rails_helper'

describe Goal do
  before do
    @u = create(:confirmed_user)
    @cat = create(:record_category, user: @u, name: "ABC")
    @cat2 = create(:record_category, user: @u, name: "DEF")
    @time = Time.zone.local(2013, 1, 1, 8)
    travel_to @time + 1.day
  end
  after do
    travel_back
  end
  describe '#recreate_from_parsed' do
    it "reconstructs direct comparisons" do
      g = Goal.new(expression_type: :direct, record_category: @cat, target: 5, op: '>=')
      expect(g.recreate_from_parsed).to eq "[#{@cat.id}] >= 5.00"
    end
    it "reconstructs category comparisons" do
      g = Goal.new(expression_type: :categories, record_category: @cat, target: @cat2, op: '>=')
      expect(g.recreate_from_parsed).to eq "[#{@cat.id}] >= [#{@cat2.id}]"
    end
    it "reconstructs range comparisons" do
      g = Goal.new(expression_type: :range, record_category: @cat, val1: '1', op1: '<=', val2: '2', op2: '<')
      expect(g.recreate_from_parsed).to eq "1.00 <= [#{@cat.id}] < 2.00"
    end
  end
  describe '#set_from_form' do
    it "reconstructs direct comparisons" do
      g = Goal.new(user: @u)
      g.set_from_form({expression_type: :direct, direct_record_category_id: @cat.id, direct_target: 5, direct_op: '>='})
      expect(g.recreate_from_parsed).to eq "[#{@cat.id}] >= 5.00"
    end
    it "reconstructs category comparisons" do
      g = Goal.new(user: @u)
      g.set_from_form({expression_type: :categories, categories_record_category_id: @cat.id, categories_target_id: @cat2.id, categories_op: '>='})
      expect(g.recreate_from_parsed).to eq "[#{@cat.id}] >= [#{@cat2.id}]"
    end
    it "reconstructs range comparisons" do
      g = Goal.new(user: @u)
      g.set_from_form({expression_type: :range, range_record_category_id: @cat.id, range_val1: '1', range_op1: '<=', range_val2: '2', range_op2: '<'})
      expect(g.recreate_from_parsed).to eq "1.00 <= [#{@cat.id}] < 2.00"
    end
    it "reconstructs active goals" do
      g = Goal.new(user: @u)
      g.set_from_form({expression_type: :range, range_record_category_id: @cat.id, range_val1: '1', range_op1: '<=', range_val2: '2', range_op2: '<', active: true})
      expect(g).to be_active
    end
  end
  describe '#active=' do
    it "sets active if non-nil" do
      g = FactoryGirl.build_stubbed(:goal)
      g.active = true
      expect(g).to be_active
    end
    it "sets active if non-nil" do
      g = FactoryGirl.build_stubbed(:goal)
      g.active = nil
      expect(g).to_not be_active
    end
  end
  describe '#parse_expression' do
    context "when the category does not exist" do
      it "returns blank and logs the error" do
        goal = build_stubbed(:goal, :daily, expression: "[XYZ]<5", user: @u, label: 'Does not exist')
        expect(goal.parse_expression).to eq({ label: 'Does not exist', performance: nil, target: nil, success: nil, text: ''})
      end
    end
    context "when doing a comparison by number" do
      it "looks up the right category" do
        create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
        goal = build_stubbed(:goal, :daily, expression: "[#{@cat.id}]<5", user: @u)
        expect(goal.parse_expression[:success]).to be(true)
      end
    end
    context "when doing a direct comparison by name" do
      before do
        create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
      end
      it "knows how far we are in terms of the goal" do
        goal = build_stubbed(:goal, :daily, expression: "[ABC]<5", user: @u)
        expect(goal.parse_expression).to eq({
          label: goal.label,
          performance: 1,
          target: 5,
          success: true,
          text: '1.0'
        })
      end
      it "can detect goals in progress" do
        goal = build_stubbed(:goal, :daily, expression: "[ABC]>5", user: @u)
        expect(goal.parse_expression).to eq({
          label: goal.label,
          performance: 1,
          target: 5,
          success: false,
          text: '1.0'
        })
      end
    end
    context "when comparing two categories" do
      shared_context "when A and B are roughly equal" do
        context "when comparing A < B" do
          let(:expression) { "[ABC] < [DEF]" }
          it { should be(false) }
        end
        context "when comparing B < A" do
          let(:expression) { "[DEF] < [ABC]" }
          it { should be(false) }
        end
        context "when comparing A <= B" do
          let(:expression) { "[ABC] <= [DEF]" }
          it { should be(true) }
        end
        context "when comparing B <= A" do
          let(:expression) { "[DEF] <= [ABC]" }
          it { should be(true) }
        end
        context "when comparing A >= B" do
          let(:expression) { "[ABC] >= [DEF]" }
          it { should be(true) }
        end
        context "when comparing B >= A" do
          let(:expression) { "[DEF] >= [ABC]" }
          it { should be(true) }
        end
        context "when comparing A > B" do
          let(:expression) { "[ABC] > [DEF]" }
          it { should be(false) }
        end
        context "when comparing B > A" do
          let(:expression) { "[DEF] > [ABC]" }
          it { should be(false) }
        end
        context "when comparing A = B" do
          let(:expression) { "[ABC] = [DEF]" }
          it { should be(true) }
        end
        context "when comparing A != B" do
          let(:expression) { "[ABC] != [DEF]" }
          it { should be(false) }
        end
      end
      shared_context "when A is significantly less than B" do
        context "when comparing A < B" do
          let(:expression) { "[ABC] < [DEF]" }
          it { should be(true) }
        end
        context "when comparing B < A" do
          let(:expression) { "[DEF] < [ABC]" }
          it { should be(false) }
        end
        context "when comparing A <= B" do
          let(:expression) { "[ABC] <= [DEF]" }
          it { should be(true) }
        end
        context "when comparing B <= A" do
          let(:expression) { "[DEF] <= [ABC]" }
          it { should be(false) }
        end
        context "when comparing B > A" do
          let(:expression) { "[DEF] > [ABC]" }
          it { should be(true) }
        end
        context "when comparing A > B" do
          let(:expression) { "[ABC] > [DEF]" }
          it { should be(false) }
        end
        context "when comparing B >= A" do
          let(:expression) { "[DEF] >= [ABC]" }
          it { should be(true) }
        end
        context "when comparing A >= B" do
          let(:expression) { "[ABC] >= [DEF]" }
          it { should be(false) }
        end
        context "when comparing A = B" do
          let(:expression) { "[ABC] = [DEF]" }
          it { should be(false) }
        end
        context "when comparing A != B" do
          let(:expression) { "[ABC] != [DEF]" }
          it { should be(true) }
        end
      end
      shared_context "when A is significantly greater than B" do
        context "when comparing A < B" do
          let(:expression) { "[ABC] < [DEF]" }
          it { should be(false) }
        end
        context "when comparing B < A" do
          let(:expression) { "[DEF] < [ABC]" }
          it { should be(true) }
        end
        context "when comparing A <= B" do
          let(:expression) { "[ABC] <= [DEF]" }
          it { should be(false) }
        end
        context "when comparing B <= A" do
          let(:expression) { "[DEF] <= [ABC]" }
          it { should be(true) }
        end
        context "when comparing B > A" do
          let(:expression) { "[DEF] > [ABC]" }
          it { should be(false) }
        end
        context "when comparing A > B" do
          let(:expression) { "[ABC] > [DEF]" }
          it { should be(true) }
        end
        context "when comparing B >= A" do
          let(:expression) { "[DEF] >= [ABC]" }
          it { should be(false) }
        end
        context "when comparing A >= B" do
          let(:expression) { "[ABC] >= [DEF]" }
          it { should be(true) }
        end
        context "when comparing A = B" do
          let(:expression) { "[ABC] = [DEF]" }
          it { should be(false) }
        end
        context "when comparing A != B" do
          let(:expression) { "[ABC] != [DEF]" }
          it { should be(true) }
        end
      end
      
      context "when A and B are 0" do
        subject { build_stubbed(:goal, :daily, expression: expression, user: @u).parse_expression[:success] }
        include_context "when A and B are roughly equal"
      end

      context "when A is something and B is 0" do
        before do
          create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
        end
        subject { build_stubbed(:goal, :daily, expression: expression, user: @u).parse_expression[:success] }
        include_context "when A is significantly greater than B"
      end
      context "when B is something and A is 0" do
        before do
          create(:record, user: @u, record_category: @cat2, manual: true, timestamp: @time + 1.hour, end_timestamp: @time + 2.hours + 5.minutes)
        end
        subject { build_stubbed(:goal, :daily, expression: expression, user: @u).parse_expression[:success] }
        include_context "when A is significantly less than B"
      end
      context "when A is significantly different from B" do
        before do
          create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
          create(:record, user: @u, record_category: @cat2, manual: true, timestamp: @time + 1.hour, end_timestamp: @time + 2.hours + 5.minutes)
        end
        subject { build_stubbed(:goal, :daily, expression: expression, user: @u).parse_expression[:success] }
        include_context "when A is significantly less than B"        
      end
      context "when A is approximately equal to B" do
        before do
          create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
          create(:record, user: @u, record_category: @cat2, manual: true, timestamp: @time + 1.hour, end_timestamp: @time + 2.hours + 1.second)
        end
        subject { build_stubbed(:goal, :daily, expression: expression, user: @u).parse_expression[:success] }
        include_context "when A and B are roughly equal"
      end
    end
    context "when comparing a range" do
      context "when A is 0" do
        it "handles 0 < A < X" do
          expect(build_stubbed(:goal, :daily, expression: "0 < [ABC] < 1", user: @u).parse_expression[:success]).to be(false)
        end
        it "handles 0 <= A < X" do
          expect(build_stubbed(:goal, :daily, expression: "0 <= [ABC] < 1", user: @u).parse_expression[:success]).to be(true)
        end
      end
      context "when there is time tracked" do
        before do
          create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
        end
        subject { create(:goal, :daily, expression: expression, user: @u).parse_expression[:success] }
        context "when A is less than the start of the range" do
          let(:expression) { "2 < [ABC] < 3" }
          it { should be(false) }
        end
        context "when A is equal to the start of the range, but we're looking for strict comparison" do
          let(:expression) { "1 < [ABC] < 3" }
          it { should be(false) }
        end
        context "when A is equal to the start of the range, and we're checking <=" do
          let(:expression) { "1 <= [ABC] < 3" }
          it { should be(true) }
        end
        context "when A is within the range" do
          let(:expression) { "0.5 <= [ABC] < 3" }
          it { should be(true) }
        end
        context "when A is at the end of the range, but we're looking for strict comparison" do
          let(:expression) { "0.5 <= [ABC] < 1" }
          it { should be(false) }
        end
        context "when A is at the end of the range, and we're checking <=" do
          let(:expression) { "0.5 <= [ABC] <= 1" }
          it { should be(true) }
        end
        context "when A is beyond the end of the range" do
          let(:expression) { "0.5 <= [ABC] <= 0.7" }
          it { should be(false) }
        end
      end
    end
  end
  describe '#range' do
    it 'spans a week' do
      expect(build_stubbed(:goal, :weekly, expression: '[ABC] < 5').range).to eq (Time.zone.local(2012, 12, 29)..Time.zone.local(2013, 1, 5))
    end
    it 'spans a month' do
      expect(build_stubbed(:goal, :monthly, expression: '[ABC] < 5').range).to eq (Time.zone.local(2013, 1, 1)..Time.zone.now)
    end
    it 'spans the last 24 hours' do
      expect(build_stubbed(:goal, :daily, expression: '[ABC] < 5').range).to eq (Time.zone.local(2013, 1, 1, 8)..Time.zone.local(2013, 1, 2, 8))
    end
    it 'spans today' do
      expect(build_stubbed(:goal, :today, expression: '[ABC] < 5').range).to eq (Time.zone.local(2013, 1, 2)..Time.zone.now)
    end
  end
  describe '#check_goals' do
    before do
      create(:record, user: @u, record_category: @cat, manual: true, timestamp: @time, end_timestamp: @time + 1.hour)
      create(:record, user: @u, record_category: @cat2, manual: true, timestamp: @time + 1.hour, end_timestamp: @time + 2.hours + 6.minutes)
      create(:goal, :daily, user: @u, expression: '[ABC] < 5', label: 'Goal 1')
      create(:goal, :daily, user: @u, expression: '[DEF] > 5', label: 'Goal 2')
      create(:goal, :daily, user: @u, expression: '[Does not exist] > 5', label: 'Goal 3')
      create(:goal, :daily, user: @u, expression: '[ABC] > 0', label: 'Inactive', status: 'inactive')
    end
    subject { Goal.check_goals(@u) }
    it "should have the results we expect" do
      expect(subject.size).to eq 3
      {'Goal 1' => {class: 'good', performance_color: Goal::GOOD_COLOR, performance: 1.0, target: 5.0, success: true, text: '1.0', label: 'Goal 1', status: nil},
        'Goal 2' => {class: 'attention', performance_color: Goal::ATTENTION_COLOR, performance: 1.1, target: 5.0, success: false, text: '1.1', label: 'Goal 2', status: nil},
        'Does not exist' => {class: 'attention', performance_color: Goal::ATTENTION_COLOR, performance: nil, target: nil, success: nil, text: '', label: 'Does not exist', status: nil}}.each do |k, v|
        v.each do |k2, expected|
          expect(subject[k][k2]).to eq expected
        end
      end
    end
    it "should include only active goals" do
      expect(subject.size).to eq 3
    end
  end
  describe '#active?' do
    it "should detect inactive goals" do
      g = build_stubbed(:goal, :inactive, :weekly, expression: '[ABC] > 0', user: @u)
      expect(g).to_not be_active
    end
    it "should detect active goals" do
      g = build_stubbed(:goal, :weekly, expression: '[ABC] > 0', user: @u)
      expect(g).to be_active
    end
    
  end
  describe '#to_comma' do
    it "should convert to CSV" do
      g = build_stubbed(:goal, :daily, user: @u, expression: '[ABC] < 5', label: 'Goal 1')
      expect(g.to_comma).to eq [g.id.to_s, 'Goal 1', '[ABC] < 5', 'daily']
    end
  end
end
