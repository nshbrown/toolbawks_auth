class AddLoginToken < ActiveRecord::Migration
  def self.up
    add_column :toolbawks_users, :login_token, :string, :limit => 40
  end

  def self.down
    remove_column :toolbawks_users, :login_token
  end
end