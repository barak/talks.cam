class AddCreatedAtAndUpdatedAtToList < ActiveRecord::Migration
  def self.up
    add_column :lists, :created_at, :datetime
    add_column :lists, :updated_at, :datetime
  end

  def self.down
    remove_column :lists, :created_at
    remove_column :lists, :updated_at
  end
end
