class CreateListUsers < ActiveRecord::Migration
  def self.up
    rename_table :lists_users, :list_users
    add_column :list_users, :id, :primary_key
  end

  def self.down
    remove_column :list_users, :id
    rename_table :list_users, :lists_users
  end
end
