require 'spec_helper'

describe "contexts/index.html.haml" do
  before(:each) do
    setup_ability
    @user = Factory(:user)
    as_user(@user)
    assign(:contexts, [
      stub_model(Context,
        :name => "Name",
        :rules => "MyText",
        :user => @user
      ),
      stub_model(Context,
        :name => "Name",
        :rules => "MyText",
        :user => @user         
      )
    ])
  end

  it "renders a list of contexts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
