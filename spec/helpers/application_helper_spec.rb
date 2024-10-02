require 'rails_helper'

describe ApplicationHelper, :type => :helper do
  describe '#set_focus_to_id' do
    it "focuses on the ID" do
      helper.set_focus_to_id("#x").should =~ /#x/
      helper.set_focus_to_id("#x").should =~ /focus/
    end
  end
  describe '#clothing_thumbnail' do
    before do
      @c = create(:clothing, image: fixture_file_upload('/files/sample-color-ff0000.png', 'image/png'))
    end
    it "requires clothing" do
      helper.clothing_thumbnail(nil).should be_nil
    end
    it "displays the last time something was worn" do
      @c.last_worn = Time.zone.now - 1.day
      helper.clothing_thumbnail(@c).should match '1 day ago'
    end
    it "shows tiny thumbnail" do
      expect(@c.image).to receive(:url).with(:small)
      expect(helper.clothing_thumbnail(@c, size: :tiny)).to match "clothing_#{@c.id}"
    end
    it "includes large thumbnail if specified" do
      expect(@c.image).to receive(:url).with(:large)
      expect(helper.clothing_thumbnail(@c, size: :large)).to match "clothing_#{@c.id}"
    end
    it "includes medium thumbnail by default" do
      expect(@c.image).to receive(:url).with(:medium)
      expect(helper.clothing_thumbnail(@c)).to match "clothing_#{@c.id}"
    end
  end
  describe '#date_ago_future' do
    it "shows the dates for the future" do
      expect(helper.date_ago_future(Time.zone.local(2100, 1, 1))).to be_within(1.day).of(Time.zone.local(2100, 1, 1))
    end
    it "shows 'today'" do
      expect(helper.date_ago_future(Time.zone.now)).to eq 'today'
    end
    it "shows days ago" do
      expect(helper.date_ago_future(Time.zone.now - 1.day)).to eq '1 day ago'
      expect(helper.date_ago_future(Time.zone.now - 2.days)).to eq '2 days ago'
    end
  end
  describe '#resource_name' do
    it "returns the resource name" do
      expect(helper.resource_name).to eq :user
    end
  end
  describe '#resource' do
    it "returns a resource" do
      expect(helper.resource.class).to eq User
    end
  end
  describe '#devise_mapping' do
    it "returns user" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      expect(helper.devise_mapping).to eq Devise.mappings[:user]
    end
  end
  describe '#conditional_html' do
    it 'returns IE code' do
      expect(helper.conditional_html('en')).to match 'IE 7'
    end
  end
  describe '#object_labels' do
    it "shows the status" do
      expect(helper.object_labels(build_stubbed(:clothing, status: 'donated'))).to match 'donated'
    end
    it "shows private" do
      expect(helper.object_labels(build_stubbed(:tap_log_record, note: '!private'))).to match I18n.t('app.general.private')
    end
  end
  describe '#actions' do
    context "when logged in" do
      before do
        @user = create(:user, :confirmed)
        allow(helper).to receive(:can?).and_return(true)
        allow(helper).to receive(:managing?).and_return(true)
        allow(helper).to receive(:current_account).and_return(@user)
      end
      context "when given a memory" do
        subject { helper.actions(build_stubbed(:memory, user: @user)).join('') }
        it { should match 'edit' }
        it { should match 'delete' }
      end
      context "when given a record category - activity" do
        subject { helper.actions(build_stubbed(:record_category, user: @user)).join('') }
        it { should match 'edit' }
        it { should match I18n.t('record_categories.show.start_activity') }
        it { should_not match I18n.t('record_categories.show.record') }
      end
      context "when given a record category - record" do
        subject { helper.actions(build_stubbed(:record_category, user: @user, category_type: 'record')).join('') }
        it { should match 'edit' }
        it { should match I18n.t('record_categories.show.record') }
      end
      context "when given a record" do
        subject { helper.actions(build_stubbed(:record, user: @user)).join('') }
        it { should match 'edit' }
        it { should match 'delete' }
        it { should match 'clone' }
      end
      context "when given a context" do
        subject { helper.actions(build_stubbed(:context, user: @user)).join('') }
        it { should match 'edit' }
        it { should match 'Start' }
      end
      context "when given a goal" do
        subject { helper.actions(build_stubbed(:goal, user: @user)).join('') }
        it { should match 'edit' }
        it { should match 'delete' }
      end
    end
    context "when not logged in" do
      before do
        @user = create(:user, :demo)
        allow(helper).to receive(:can?).and_return(false)
        allow(helper).to receive(:managing?).and_return(false)
        allow(helper).to receive(:current_account).and_return(create(:user, :confirmed))
      end
      context "when given a memory" do
        subject { helper.actions(build_stubbed(:memory, user: @user)).join('') }
        it { should_not match 'edit' }
        it { should_not match 'delete' }
        it { should match I18n.t('app.general.view') }
      end
      context "when given a record category - activity" do
        subject { helper.actions(build_stubbed(:record_category, user: @user)).join('') }
        it { should_not match 'edit' }
        it { should_not match I18n.t('record_categories.show.start_activity') }
        it { should_not match I18n.t('record_categories.show.record') }
      end
      context "when given a record category - record" do
        subject { helper.actions(build_stubbed(:record_category, user: @user, category_type: 'record')).join('') }
        it { should_not match 'edit' }
        it { should_not match I18n.t('record_categories.show.record') }
      end
      context "when given a record" do
        subject { helper.actions(build_stubbed(:record, user: @user)).join('') }
        it { should_not match 'edit' }
        it { should_not match 'delete' }
        it { should_not match 'clone' }
      end
      context "when given a context" do
        subject { helper.actions(build_stubbed(:context, user: @user)).join('') }
        it { should_not match 'edit' }
        it { should_not match 'Start' }
      end
    end
  end
  describe '#tags' do
    it "returns a list of tags" do
      expect(helper.tags(create(:clothing, user: @user, tag_list: 'a, b'))).to eq 'a, b'
    end
  end
  describe '#after_title' do
    it "stores the info if given a string" do
      expect(helper).to receive(:content_for).with(:after_title)
      helper.after_title('hello')
    end
    it "stores the info if given a block" do
      expect(helper).to receive(:content_for).with(:after_title)
      helper.after_title do 'hello' end
    end
  end
  describe '#active_menu' do
    let(:request) { double('request', :fullpath => '/time') }
    it "matches regular expressions" do
      expect(active_menu(/\/time/)).to eq 'active'
    end
    it "does not match regular expressions if inactive" do
      expect(active_menu(/\/dashboard/)).to eq 'inactive'
    end
  end
  describe '#duration' do
    it "shows as time" do
      allow(helper).to receive(:params).and_return({ display_type: 'time' })
      expect(helper.duration(60 * 6)).to eq '0:06'
    end
    it "shows as decimal" do
      allow(helper).to receive(:params).and_return({ display_type: 'decimal' })
      expect(helper.duration(60 * 6)).to eq '0.1'
    end
  end
  describe '#record_category_breadcrumbs' do
    it "shows a hierarchy" do
      @u = create(:user, :confirmed)
      @c1 = create(:record_category, user: @u, name: 'AB')
      @c2 = create(:record_category, user: @u, parent: @c1, name: 'CD')
      expect(helper.record_category_breadcrumbs(@c2)).to match 'AB'
      expect(helper.record_category_breadcrumbs(@c2)).to_not match 'CD'
    end
  end
  describe '#delete_icon' do
    it "gets the path when passed an object" do
      expect(helper.delete_icon(create(:user, :confirmed))).to match /user/
    end
  end
  describe "#record_category_full" do
    it "requires a category" do
      expect(helper.record_category_full(nil)).to eq '(deleted?)'
    end
    it "displays the full name" do
      @u = create(:user, :confirmed)
      @c1 = create(:record_category, user: @u, name: 'AB')
      @c2 = create(:record_category, user: @u, parent: @c1, name: 'CD')
      expect(helper.record_category_full(@c2)).to match 'AB'
      expect(helper.record_category_full(@c2)).to match 'CD'
    end
  end
  describe "#record_data" do
    before do
      @u = create(:user, :confirmed)
      @c1 = create(:record_category, user: @u, name: 'AB', data: { note: { key: 'note', label: 'Note', type: 'text' }  })
    end
    it "returns blank if there is no data" do
      @record_blank = create(:record, user: @u, record_category: @c1)
      expect(helper.record_data(@record_blank.data)).to eq ''
    end
    it "returns blank if there is zero data" do
      @record_blank = create(:record, user: @u, record_category: @c1, data: {})
      expect(helper.record_data(@record_blank.data)).to eq ''
    end
    it "displays one item" do
      @record = create(:record, user: @u, record_category: @c1, data: { note: 'Note' })
      expect(helper.record_data(@record.data)).to eq '<strong>Note</strong>: Note'
    end
    it "displays multiple items" do
      @c2 = create(:record_category, user: @u, name: 'AB', data: { note: { key: 'note', label: 'Note', type: 'text' },
                     note2: { key: 'another', label: 'Another', type: 'text' } })
      @record2 = create(:record, user: @u, record_category: @c2, data: { note: 'NValue', another: 'AValue' })
      expect(helper.record_data(@record2.data)).to match '<strong>Note</strong>: NValue'
      expect(helper.record_data(@record2.data)).to match '<strong>Another</strong>: AValue'
    end
  end
  describe '#graph_time_entry' do
    before do
      @user = create(:user, :confirmed)
    end
    it "outputs Javascript with the category color" do
      cat = create(:record_category, color: '#000')
      @row = [Time.zone.now, Time.zone.now + 1.hour, create(:record, user: @user, record_category: cat)]
      expect(helper.graph_time_entry('canvas', 0, @row)).to match '1:00'
      expect(helper.graph_time_entry('canvas', 0, @row)).to match '#000'
    end
    it "outputs Javascript default color" do
      @row = [Time.zone.now, Time.zone.now + 1.hour, create(:record, user: @user)]
      expect(helper.graph_time_entry('canvas', 0, @row)).to match '1:00'
      expect(helper.graph_time_entry('canvas', 0, @row)).to match '#ccc'
    end
  end
  describe '#graph_time_total' do
    it "uses the category color" do
      cat = create(:record_category, color: '#000')
      rec = create(:record, timestamp: Time.zone.now, end_timestamp: Time.zone.now + 1.hour, record_category: cat)
      x = helper.graph_time_total('canvas', Time.zone.now.midnight..(Time.zone.now.midnight + 1.day), Time.zone.now.midnight, rec.record_category, 3600)
      expect(x).to match '#000'
    end
    it "uses the default color" do
      rec = create(:record, timestamp: Time.zone.now, end_timestamp: Time.zone.now + 1.hour)
      x = helper.graph_time_total('canvas', Time.zone.now.midnight..(Time.zone.now.midnight + 1.day), Time.zone.now.midnight, rec.record_category, 3600)
      expect(x).to match rec.record_category.name
      expect(x).to match '#ccc'
    end
  end
  describe '#record_data_input' do
    before :each do
      @u = create(:user, :confirmed)
      @c2 = create(:record_category, user: @u, name: 'AB', data: { note: { key: 'note', label: 'Note', type: 'text' },
                     note2: { key: 'another', label: 'Another', type: 'number' } })
      @record2 = create(:record, user: @u, record_category: @c2, data: { note: 'NValue', another: 'AValue' })
    end
    context "when given a textarea" do
      subject { helper.record_data_input(@record2, @c2.data[:note]) }
      it { should match 'textarea' }
      it { should match 'note' }
    end
    context "when given a number" do
      subject { helper.record_data_input(@record2, @c2.data[:note2]) }
      it { should match 'input' }
      it { should match 'another' }
    end
  end
  describe '#explain_op(op)' do
    it "turns operators into English" do
      list = {'>' => 'should be greater than',
        '>=' => 'should be greater than or equal to',
        '<=' => 'should be less than or equal to',
        '<' => 'should be less than',
        '=' => 'should be equal to',
        '!=' => 'should not be equal to'}
      list.each do |k,v|
        expect(helper.explain_op(k)).to eq v
      end
    end
  end

end
