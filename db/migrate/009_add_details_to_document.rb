class AddDetailsToDocument < ActiveRecord::Migration
  def self.up
    add_column "documents", "user_id", :integer
    add_column "documents", "administrator_only", :boolean
    add_column "document_versions", "user_id", :integer
    add_column "document_versions", "administrator_only", :string
  end

  def self.down
    remove_column "documents", "user_id"
    remove_column "documents", "administrator_only"
    remove_column "document_versions", "user_id"
    remove_column "document_versions", "administrator_only"
  end
end
