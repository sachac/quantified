class AddRoleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :role, :string
    User.reset_column_information
    User.where('email="sacha@sachachua.com"').update_all('role="admin"')
  end

  def self.down
    remove_column :users, :role
  end
end
