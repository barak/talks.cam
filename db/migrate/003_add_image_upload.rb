class AddImageUpload < ActiveRecord::Migration
  def self.up
    add_column :talks, :image, :string
    add_column :users, :image, :string
    add_column :lists, :image, :string
  end

  def self.down
    remove_column :talks, :image
    remove_column :users, :image
    remove_column :lists, :image
  end
end
