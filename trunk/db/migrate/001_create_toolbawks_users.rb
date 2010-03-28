class CreateToolbawksUsers < ActiveRecord::Migration
  def self.up
    create_table :toolbawks_users do |t|
      t.column :email, :string
      t.column :password, :string
      t.column :salt, :string, :limit => 8
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :toolbawks_users
  end
end