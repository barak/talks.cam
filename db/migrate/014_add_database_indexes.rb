class AddDatabaseIndexes < ActiveRecord::Migration

  def self.up
    add_index :documents, :name
    
    add_index :email_subscriptions, :user_id
    add_index :email_subscriptions, :list_id
    
    add_index :list_lists, :list_id
    add_index :list_lists, :child_id
    
    add_index :list_talks, :list_id
    add_index :list_talks, :talk_id
    
    add_index :lists, :name
    add_index :lists, :ex_directory

    add_index :lists_users, :list_id
    add_index :lists_users, :user_id
    
    add_index :related_lists, [:related_id,:related_type]
    add_index :related_lists, :list_id
    add_index :related_lists, :score
    
    add_index :related_talks, [:related_id,:related_type]
    add_index :related_talks, :talk_id
    add_index :related_talks, :score
    
    add_index :talks, :start_time
    add_index :talks, :end_time
    add_index :talks, :series_id
    add_index :talks, :speaker_id
    add_index :talks, :organiser_id
    
    add_index :users, :email
  end

  def self.down
    remove_index :documents, :name

    remove_index :email_subscriptions, :user_id
    remove_index :email_subscriptions, :list_id

    remove_index :list_lists, :list_id
    remove_index :list_lists, :child_id

    remove_index :list_talks, :list_id
    remove_index :list_talks, :talk_id

    remove_index :lists, :name
    remove_index :lists, :ex_directory

    remove_index :lists_users, :list_id
    remove_index :lists_users, :user_id

    remove_index :related_lists, [:related_id,:related_type]
    remove_index :related_lists, :list_id
    remove_index :related_lists, :score

    remove_index :related_talks, [:related_id,:related_type]
    remove_index :related_talks, :talk_id
    remove_index :related_talks, :score

    remove_index :talks, :start_time
    remove_index :talks, :end_time
    remove_index :talks, :series_id
    remove_index :talks, :speaker_id
    remove_index :talks, :organiser_id

    remove_index :users, :email
  end
end
