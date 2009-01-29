class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.column :name, :string
      t.column :body, :text
      t.column :html, :text
    end
    Document.create_versioned_table
  end

  def self.down
    drop_table :documents
    drop_table :documents_versions
  end
end
