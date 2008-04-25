class AddExDirectoryToTalk < ActiveRecord::Migration
  def self.up
    add_column "talks", "ex_directory", :boolean, :default => false
  end

  def self.down
    remove_column "talks", "ex_directory"
  end
end
