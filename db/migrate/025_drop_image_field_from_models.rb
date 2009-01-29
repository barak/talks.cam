class DropImageFieldFromModels < ActiveRecord::Migration
  def self.up
    remove_column :users, :image
    remove_column :talks, :image
    remove_column :lists, :image
  end

  def self.down
    add_column :users, :image, :string
    add_column :talks, :image, :string
    add_column :lists, :image, :string
  end
end
