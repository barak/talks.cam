class AddExDirectory < ActiveRecord::Migration
  def self.up
    add_column "lists", "ex_directory", :boolean, :default => false
  end

  def self.down
    remove_column "lists", "ex_directory"
  end
end
