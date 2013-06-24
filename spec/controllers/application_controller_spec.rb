require 'spec_helper'
describe ApplicationController do
  describe '#filter_sortable_column_order' do
    it "limits the parameter to the columns specified" do
      subject.stub!(:params).and_return({'sort' => 'count'})
      x = subject.send(:filter_sortable_column_order, ['name', 'count'])
      x.should == 'count asc'
    end
    it "handles descending" do
      subject.stub!(:params).and_return({'sort' => '-count'})
      x = subject.send(:filter_sortable_column_order, ['name', 'count'])
      x.should == 'count desc'
    end
    it "returns the first if the choice is not included" do
      subject.stub!(:params).and_return({'sort' => 'DROP DATABASE'})
      x = subject.send(:filter_sortable_column_order, ['name', 'count'])
      x.should == 'name'
    end
    it "returns the default if specified and the choice is not included" do
      subject.stub!(:params).and_return({'sort' => 'DROP DATABASE'})
      x = subject.send(:filter_sortable_column_order, ['name', 'count'], 'count')
      x.should == 'count'
    end
  end
  describe "#go_to" do
    it "redirects to a destination if specified" do
      subject.stub!(:params).and_return({destination: time_dashboard_path})
      subject.should_receive(:redirect_to).with(time_dashboard_path)
      subject.send(:go_to, root_path)
    end
    it "goes to the regular URL if a different destination is not specified" do
      subject.should_receive(:redirect_to).with(root_path)
      subject.send(:go_to, root_path)
    end
  end
  describe "#add_flash" do
    context "when given a hash" do
      it "stores all the messages" do
        subject.send(:add_flash, { notice: 'Hello', error: 'Uh oh' })
        flash[:notice].should == 'Hello'
        flash[:error].should == 'Uh oh'
      end
    end
    context "when adding a string to an string" do
      it "stores the value" do
        subject.send(:add_flash, :notice, 'Hello')
        subject.send(:add_flash, :notice, 'World')
        flash[:notice].should == ['Hello', 'World']
      end
    end
  end
  describe "#after_sign_in_path_for" do
    context "when a destination is specified" do
      it "returns the destination" do
        subject.stub!(:params).and_return({destination: 'home'})
        subject.send(:after_sign_in_path_for, create(:user, :confirmed)).should == 'home'
      end
      it "returns the root path if no destination is specified" do
        subject.stub!(:params).and_return({})
        subject.send(:after_sign_in_path_for, create(:user, :confirmed)).should == root_path
      end
    end
  end
end
