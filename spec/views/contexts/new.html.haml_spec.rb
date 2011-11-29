require 'spec_helper'

describe "contexts/new.html.haml" do
  before(:each) do
    @user = Factory(:user)
    assign(:context, stub_model(Context,
      :name => "MyString",
      :rules => "MyText",
      :user => @user
    ).as_new_record)
  end

  it "renders new context form" do
    render
    
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => contexts_path, :method => "post" do
      assert_select "input#context_name", :name => "context[name]"
      assert_select "textarea#context_rules", :name => "context[rules]"
    end
  end
end
