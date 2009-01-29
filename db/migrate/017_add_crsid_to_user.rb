class AddCrsidToUser < ActiveRecord::Migration
  def self.up
    add_column "users", "crsid", :string
    add_index 'users', 'crsid'
  end

  def self.down
    remove_column "users", "crsid"
    drop_index 'users', 'crsid'
  end
end
