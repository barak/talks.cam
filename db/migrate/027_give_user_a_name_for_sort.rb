class GiveUserANameForSort < ActiveRecord::Migration
  def self.up
    add_column :users, :name_in_sort_order, :string
    add_column :users, :ex_directory, :boolean, :default => true
    add_column :users, :created_at, :time
    add_column :users, :updated_at, :time
    add_index :users, :name_in_sort_order
  end

  def self.down
    remove_index :users, :name_in_sort_order
    remove_column :users, :name_in_sort_order
    remove_column :users, :created_at
    remove_column :users, :updated_at
    remove_column :users, :ex_directory
  end
end
