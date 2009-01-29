class CreateEmailSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :email_subscriptions do |t|
      t.column :user_id, :integer
      t.column :list_id, :integer
    end
  end

  def self.down
    drop_table :email_subscriptions
  end
end
