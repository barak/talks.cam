class RemoveDefaultFromTalk < ActiveRecord::Migration
  def self.up
    change_column :talks, "title", :string, :default => ''
  end

  def self.down
    change_column :talks, "title", :string, :default => "To be determined"
  end
end
