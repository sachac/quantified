require 'spec_helper'

describe RecordCategory do
  describe "#as_child_id" do
    it "handles identity" do
      RecordCategory.as_child_id('1.2', '1.2').should be_nil
    end
    it "handles direct child" do
      RecordCategory.as_child_id('1.2', '1.2.3').should == '3'
    end
    it "handles descendant" do
      RecordCategory.as_child_id('1.2', '1.2.3.4').should == '3'
    end
    it "handles non-children" do
      RecordCategory.as_child_id('1.2', '1.3.4.5').should be_nil
    end
    it "is not confused by substrings" do
      RecordCategory.as_child_id('1.2', '1.21').should be_nil
    end
  end
end
