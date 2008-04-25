class ExtendAffiliationColumn < ActiveRecord::Migration
  def self.up
    change_column :users, :affiliation, :string, :limit => 75
  end

  def self.down
    change_column :users, :affiliation, :string, :limit => 50
  end
end
