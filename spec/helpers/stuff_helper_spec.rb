require 'rails_helper'
describe StuffHelper, :type => :helper do
  before :each do
    @user = create(:user, :demo)
    @location = create(:stuff, name: "Place", user: @user)
    @location2 = create(:stuff, name: "Area", user: @user)
    @stuff = create(:stuff, name: "Thing", user: @user, location: @location, home_location: @location2)
    @stuff2 = create(:stuff, name: "Thing without location")
  end
  describe '#name_and_location' do
    context "when looking at a demo user" do
      before { allow(helper).to receive(:managing?).and_return(false) }
      it "does not display movement links" do
        expect(helper.name_and_location(@stuff)).to_not match 'return to'
      end
      it "displays location only if there is one" do
        expect(helper.name_and_location(@stuff2)).to_not match ' < '
      end
    end
    context "when logged in" do
      before { allow(helper).to receive(:managing?).and_return(true) }
      subject { helper.name_and_location(@stuff) }
      it { should match 'return to' }
      it { should match 'Thing' }
      it { should match 'Area' }
    end
  end
  describe "#move_link_to" do
    subject { helper.move_link_to(@stuff2, @location).html_safe }
    context "when looking at a demo user" do
      before { allow(helper).to receive(:managing?).and_return(false) }
      it { should_not match 'method="post"' }
    end
    context "when logged in" do
      before { allow(helper).to receive(:managing?).and_return(true) }
      it { should match 'method="post"' }
    end
  end
  describe "#location_list" do
    subject { helper.location_list(@stuff, [@location, @location2]) }
    context "when looking at a demo user" do
      before { allow(helper).to receive(:managing?).and_return(false) }
      it { should_not match 'method="post"' }
    end
    context "when logged in" do
      before { allow(helper).to receive(:managing?).and_return(true) }
      it { should match 'method="post"' }
    end
  end
  describe '#return_stuff' do
    it "should show the return link" do
      helper.return_stuff(@stuff).should match 'method="post"'
    end
  end
  describe '#set_stuff_home' do
    it "should show the return link" do
      allow(helper).to receive(:current_account).and_return(@user)
      helper.set_stuff_home(@stuff, @location).should match '=' + (@location.id.to_s)
    end
  end
  describe '#return_stuff_info' do
    it "shows the home location" do
      allow(helper).to receive(:current_account).and_return(@user)
      helper.return_stuff_info(@stuff).should match 'Area'
    end
    it "shows the set link" do
      allow(helper).to receive(:current_account).and_return(@user)
      @stuff2.location = create(:stuff)
      helper.return_stuff_info(@stuff2).should match 'Set home'
    end
  end
  describe '#recent_locations' do
    it "shows recent locations" do
      helper.recent_locations(@stuff).should match 'Place'
    end
  end
  describe '#move_stuff_link' do
    it "shows the link" do
      helper.move_stuff_link(@stuff, @location).should match "=#{@location.name}"
    end
  end
end
