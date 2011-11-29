def login(user = nil, options = {})
  user ||= Factory(:user)
  @user = user
  options[:with] ||= :email
  get root_url #(:subdomain => user.username)
  puts page.body
  click_link I18n.t('app.user.login')
  fill_in 'user[login]', :with => (options[:with] == :username? ? user.username : user.email)
  fill_in 'user[password]', :with => user.password
  click_button I18n.t('app.user.login_submit')
end
def setup_ability
  @user ||= Factory(:user)
  @ability = Object.new
  @ability.extend(CanCan::Ability)
  if defined? view
    view.stub(:current_ability) { @ability }
    view.stub(:current_user) { @user }
    view.stub(:current_account) { @user }
  end
  if defined? controller
    controller.stub(:current_ability) { @ability }
    controller.stub(:current_user) { @user }
    controller.stub(:current_account) { @user }
  end
end
def as_user(user = nil)
  user ||= Factory(:user)
  @user = user
  unless @ability
    setup_ability
  end
  sign_in @user
end
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :view
end
