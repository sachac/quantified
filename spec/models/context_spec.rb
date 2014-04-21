require 'spec_helper'

describe Context do
  it "can be converted to XML" do
    context = FactoryGirl.build_stubbed(:context)
    FactoryGirl.build_stubbed(:context_rule, context: context)
    xml = context.to_xml
    xml.should match 'context-rules'
  end
  it "can be converted to JSON" do
    context = FactoryGirl.build_stubbed(:context)
    FactoryGirl.build_stubbed(:context_rule, context: context)
    s = context.to_json
    s.should match 'context_rules'
  end
  it "updates the text summary of rules" do
    user = FactoryGirl.create(:confirmed_user)
    context = FactoryGirl.create(:context, name: 'Work', user: user)
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'laptop', user: user))
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'camera', user: user))
    context.reload
    context.update_rules
    context.rules.should == 'camera, laptop'
  end
  it "produces a CSV" do
    user = FactoryGirl.create(:confirmed_user)
    context = FactoryGirl.create(:context, name: 'Work', user: user)
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'laptop', user: user))
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'camera', user: user))
    context.reload
    context.update_rules
    context.to_comma[0].should == context.name
    context.to_comma[1].should == 'camera, laptop'
  end

end
