require 'rails_helper'
describe ClothingHelper, :type => :helper do
  describe 'missing_clothing_info' do
    it "detects missing images" do
      o = create(:clothing)
      expect(helper.missing_clothing_info(o)).to eq 'Needs image'
    end
    it "is fine if the image exists" do
      o = create(:clothing, image: fixture_file_upload('/files/sample-color-ff0000.png', 'image/png'))
      expect(helper.missing_clothing_info(o)).to be_blank
    end
  end
end
