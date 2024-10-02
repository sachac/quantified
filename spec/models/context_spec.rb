require 'rails_helper'

describe Context do
  it "can be converted to XML" do
    context = FactoryGirl.build_stubbed(:context)
    FactoryGirl.build_stubbed(:context_rule, context: context)
    xml = context.to_xml
    expect(xml).to match 'context-rules'
  end
  it "can be converted to JSON" do
    context = FactoryGirl.build_stubbed(:context)
    FactoryGirl.build_stubbed(:context_rule, context: context)
    s = context.to_json
    expect(s).to match 'context_rules'
  end
  it "updates the text summary of rules" do
    user = FactoryGirl.create(:confirmed_user)
    context = FactoryGirl.create(:context, name: 'Work', user: user)
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'laptop', user: user))
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'camera', user: user))
    context.reload
    context.update_rules
    expect(context.rules).to eq 'camera, laptop'
  end
  it "produces a CSV" do
    user = FactoryGirl.create(:confirmed_user)
    context = FactoryGirl.create(:context, name: 'Work', user: user)
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'laptop', user: user))
    FactoryGirl.create(:context_rule, context: context, stuff: FactoryGirl.create(:stuff, name: 'camera', user: user))
    context.reload
    context.update_rules
    expect(context.to_comma[0]).to eq context.name
    expect(context.to_comma[1]).to eq 'camera, laptop'
  end

end
