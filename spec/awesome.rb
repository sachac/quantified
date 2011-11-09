def login(user, options = {})
  options[:with] ||= :email
  get root_path(:subdomain => user.username)
  fill_in 'user[username]', :with => (options[:with] == :username? ? user.username : user.email)
  fill_in 'user[password]', :with => user.password
  click_button 'Log in'
end
