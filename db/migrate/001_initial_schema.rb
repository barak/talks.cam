class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "lists", :force => true do |t|
      t.column "name", :string
      t.column "details", :text
      t.column "type", :string, :limit => 50
      t.column "details_filtered", :text
    end

    create_table "lists_lists", :id => false, :force => true do |t|
      t.column "parent_id", :integer
      t.column "child_id", :integer
      t.column "result_of_direct_parent_id", :integer
      t.column "result_of_direct_child_id", :integer, :limit => 50
    end

    create_table "lists_talks", :id => false, :force => true do |t|
      t.column "list_id", :integer
      t.column "talk_id", :integer
    end

    create_table "lists_users", :id => false, :force => true do |t|
      t.column "list_id", :integer
      t.column "user_id", :integer
    end

    create_table "talks", :force => true do |t|
      t.column "title", :string, :default => "To be determined"
      t.column "abstract", :text
      t.column "special_message", :string
      t.column "start_time", :datetime
      t.column "end_time", :datetime
      t.column "name_of_speaker", :string
      t.column "speaker_id", :integer
      t.column "series_id", :integer
      t.column "venue_id", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "abstract_filtered", :text
    end

    create_table "users", :force => true do |t|
      t.column "email", :string
      t.column "name", :string
      t.column "password", :string, :limit => 50
      t.column "affiliation", :string, :limit => 50
      t.column "administrator", :integer, :limit => 50, :default => 0, :null => false
    end
  end

  def self.down
    drop_table 'users'
    drop_table 'talks'
    drop_table 'lists'
    drop_table 'lists_users'
    drop_table 'lists_talks'
    drop_table 'lists_lists'
  end
end
