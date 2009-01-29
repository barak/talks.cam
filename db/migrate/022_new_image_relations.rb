class NewImageRelations < ActiveRecord::Migration
  def self.up
    add_column "talks", "image_id", :integer
    add_column "lists", "image_id", :integer
    add_column "users", "image_id", :integer    
  end

  def self.down
    remove_column "talks", "image_id"
    remove_column "lists", "image_id"
    remove_column "users", "image_id"        
  end
end
