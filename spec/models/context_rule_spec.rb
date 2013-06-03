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

end
