class Serendipity < ActiveRecord::Migration
  def self.up
    create_table "related_lists" do |t|
      t.column  'related_id',     :integer
      t.column  'related_type',   :string
      t.column  'list_id',        :integer     
      t.column  'score', :float
    end
    create_table "related_talks" do |t|
      t.column  'related_id',     :integer
      t.column  'related_type',   :string
      t.column  'talk_id',        :integer     
      t.column  'score', :float      
    end
  end

  def self.down
    drop_table "related_lists"
    drop_table "related_talks"
  end
end
