require 'spec_helper'

describe ContextRule do
  it "keeps track of things that are out of place" do
    rule = FactoryGirl.create(:context_rule, :location => FactoryGirl.create(:stuff))
    rule.stuff.location = FactoryGirl.create(:stuff)
    rule.stuff.save!
    expect(ContextRule.out_of_place).to include(rule)
    expect(ContextRule.in_place).to_not include(rule)
  end  
  it "keeps track of things that are in place" do
    rule = FactoryGirl.create(:context_rule, :location => FactoryGirl.create(:stuff))
    rule.stuff.location = rule.location
    rule.stuff.save!
    expect(ContextRule.out_of_place).to_not include(rule)
    expect(ContextRule.in_place).to include(rule)
  end  
  it "can be converted to XML" do
    rule = FactoryGirl.build_stubbed(:context_rule)
    xml = rule.to_xml
    expect(xml).to match 'stuff-name'
    expect(xml).to match rule.stuff.name
    expect(xml).to match 'location-name'
    expect(xml).to match rule.location.name
  end
  it "can be converted to JSON" do
    rule = FactoryGirl.build_stubbed(:context_rule)
    s = rule.to_json
    expect(s).to match 'stuff_name'
    expect(s).to match rule.stuff.name
    expect(s).to match 'location_name'
    expect(s).to match rule.location.name
  end

end
