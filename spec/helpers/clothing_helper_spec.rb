require 'spec_helper'
describe ClothingHelper do
  describe 'missing_clothing_info' do
    it "detects missing images" do
      o = create(:clothing)
      helper.missing_clothing_info(o).should == 'Needs image'
    end
    it "is fine if the image exists" do
      o = create(:clothing, image: fixture_file_upload('/files/sample-color-ff0000.png'))
      helper.missing_clothing_info(o).should be_blank
    end
  end
end
