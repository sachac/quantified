require 'spec_helper'
describe User do
  it "does not allow duplicate usernames" do
    u1 = Factory(:user, :username => 'foo')
    u2 = Factory.build(:user, :username => 'Foo')
    u2.save
    u2.errors.size.should > 0
  end
  it "does not allow duplicate e-mail addresses" do
    u1 = Factory(:user, :email => 'test@example.org')
    u2 = Factory.build(:user, :email => 'TEST@example.org')
    u2.save
    u2.errors.size.should > 0
  end
end
