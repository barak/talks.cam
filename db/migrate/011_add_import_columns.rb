class AddImportColumns < ActiveRecord::Migration
  def self.up
    add_column "talks", "old_id", :integer
    add_column "users", "old_id", :integer
    add_column "lists", "old_id", :integer
  end

  def self.down
    remove_column "talks", "old_id"
    remove_column "users", "old_id"
    remove_column "lists", "old_id"
  end
end
