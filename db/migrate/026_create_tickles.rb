class CreateTickles < ActiveRecord::Migration
  def self.up
    create_table :tickles do |t|
      t.column :created_at, :datetime
      t.column :about_id, :integer
      t.column :about_type, :string
      t.column :sender_id, :integer
      t.column :recipient_email, :text
      t.column :sender_email, :string
      t.column :sender_name, :string
      t.column :sender_ip, :string
    end
  end

  def self.down
    drop_table :tickles
  end
end
