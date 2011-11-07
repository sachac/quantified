class AddUsernameToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :username, :string
    User.reset_column_information
    x = User.find_by_email('sacha@sachachua.com')
    x.username = 'sacha'
    x.save
  end

  def self.down
    remove_column :users, :username
  end
end
