def login(user, options = {})
  options[:with] ||= :email
  get root_path(:subdomain => user.username)
  click_link 'Log in'
  fill_in 'user[login]', :with => (options[:with] == :username? ? user.username : user.email)
  fill_in 'user[password]', :with => user.password
  click_button 'Log in'
end
def setup_ability
  @ability = Object.new
  @ability.extend(CanCan::Ability)
  if defined? view
    view.stub(:current_ability) { @ability }
  end
  if defined? controller
    controller.stub(:current_ability) { @ability }
  end
end
def as_user(user)
  @user = user
  if defined? controller
    controller.stub(:current_user) { @user }
  end
  if defined? view
    view.stub(:current_user) { @user }
  end
  unless @ability
    setup_ability
  end
  sign_in @user
end
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :view
end
