class ToolbawksUsersAddPasswordToken < ActiveRecord::Migration
  def self.up
    add_column :toolbawks_users, :password_token, :string, :limit => 40
  end

  def self.down
    remove_column :toolbawks_users, :password_token
  end
end