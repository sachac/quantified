require 'spec_helper'
describe TorontoLibrary do
  describe '#login' do
    it "finds the form in the login page" do
      card = FactoryGirl.create(:toronto_library)
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/login.html')), content_type: 'text/html')
      Mechanize::Form.any_instance.should_receive(:submit)
      card.login
    end
  end

  describe '#renew_items' do
    it "attempts to renew selected items" do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      Mechanize::Form.any_instance.should_receive(:submit)
      card.renew_items([FactoryGirl.create(:library_item, user: card.user, toronto_library: card, library_id: '37131168694917')])
      card.agent.page.form_with(id: 'renewitems').checkboxes_with(name: /37131168694917/).first.should be_checked
    end
  end

  describe '#renew_items_by_date' do
    it "attempts to renew items by date" do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      Mechanize::Form.any_instance.should_receive(:submit)
      card.renew_items_by_date(Time.zone.local(2013, 6, 6))
      card.agent.page.form_with(id: 'renewitems').checkboxes_with(name: /37131168694917/).first.should be_checked
      card.agent.page.form_with(id: 'renewitems').checkboxes_with(name: /37131150618767/).first.should_not be_checked
    end
  end

  describe '#list_items' do
    it "parses checked-out items" do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      card.list_items.size.should == 25
    end
  end

  describe '#request_item' do
    it "requests an item by ID and returns success" do 
      item_id = '37131047960398'
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/placehold?itemId=' + item_id, body: File.read(Rails.root.join('spec/fixtures/files/hold.html')), content_type: 'text/html')
      FakeWeb.register_uri(:post, 'https://www.torontopubliclibrary.ca/placeholdconfirmation', body: File.read(Rails.root.join('spec/fixtures/files/hold_placed.html')), content_type: 'text/html')
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      card.request_item(item_id).should == :success
    end
    it "requests an item by ID and returns failure" do 
      item_id = '37131047960398'
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/placehold?itemId=' + item_id, body: File.read(Rails.root.join('spec/fixtures/files/hold.html')), content_type: 'text/html')
      FakeWeb.register_uri(:post, 'https://www.torontopubliclibrary.ca/placeholdconfirmation', body: File.read(Rails.root.join('spec/fixtures/files/hold_failed.html')), content_type: 'text/html')
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      card.request_item(item_id).should == false
    end
    it "requests an item by ID and deals with missing forms" do 
      item_id = '37131047960398'
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/placehold?itemId=' + item_id, body: '', content_type: 'text/html')
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      card.request_item(item_id).should be_nil
    end
  end
  describe '#count_pickups' do
    it 'returns the number of items to pick up' do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      card.count_pickups!.pickup_count == 0
    end
  end

  describe '#logout' do
    it 'clicks on the logout link' do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      FakeWeb.register_uri(:get, %r|https?://(www.)?torontopubliclibrary.ca/uhtbin/.*|, body: '', content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      Mechanize::Page::Link.any_instance.should_receive(:click)
      card.logout
    end
  end
  describe '#refresh_items' do
    context 'when there are old books' do
      it 'updates books as returned' do
        card = FactoryGirl.create(:toronto_library)
        card.agent = Mechanize.new
        FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
        card.agent.get('https://www.torontopubliclibrary.ca/youraccount')

        item = FactoryGirl.create(:library_item, user: card.user, toronto_library: card, status: 'due', due: Time.zone.today, title: 'Hello world', updated_at: Time.zone.now.yesterday)
        card.stub(:login).and_return(true)
        card.refresh_items
        item.reload.status.should == 'returned'
      end
    end
    it 'loads entries' do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      card.stub(:login).and_return(true)
      card.refresh_items
      card.library_items.size.should == 25
    end
    it 'updates existing entries' do
      card = FactoryGirl.create(:toronto_library)
      card.agent = Mechanize.new
      card.stub(:login).and_return(true)
      FakeWeb.register_uri(:get, 'https://www.torontopubliclibrary.ca/youraccount', body: File.read(Rails.root.join('spec/fixtures/files/account.html')), content_type: 'text/html')
      card.agent.get('https://www.torontopubliclibrary.ca/youraccount')
      card.refresh_items
      card.refresh_items
      card.library_items.size.should == 25
    end
  end

  describe '#pickup_count' do
    it 'counts the number of items to pick up, in total' do
      user = FactoryGirl.create(:user)
      card1 = FactoryGirl.create(:toronto_library, user: user, pickup_count: 3)
      card2 = FactoryGirl.create(:toronto_library, user: user, pickup_count: 2)
      TorontoLibrary.pickup_count(user).should == 5
    end
  end

end
