require 'spec_helper'

describe ContextRule do
  it "keeps track of things that are out of place" do
    rule = FactoryGirl.create(:context_rule, :location => FactoryGirl.create(:stuff))
    rule.stuff.location = FactoryGirl.create(:stuff)
    rule.stuff.save!
    ContextRule.out_of_place.should include(rule)
    ContextRule.in_place.should_not include(rule)
  end  
  it "keeps track of things that are in place" do
    rule = FactoryGirl.create(:context_rule, :location => FactoryGirl.create(:stuff))
    rule.stuff.location = rule.location
    rule.stuff.save!
    ContextRule.out_of_place.should_not include(rule)
    ContextRule.in_place.should include(rule)
  end  
  it "can be converted to XML" do
    rule = FactoryGirl.create(:context_rule)
    xml = rule.to_xml
    xml.should match 'stuff-name'
    xml.should match rule.stuff.name
    xml.should match 'location-name'
    xml.should match rule.location.name
  end
  it "can be converted to JSON" do
    rule = FactoryGirl.create(:context_rule)
    s = rule.to_json
    s.should match 'stuff_name'
    s.should match rule.stuff.name
    s.should match 'location_name'
    s.should match rule.location.name
  end

end
