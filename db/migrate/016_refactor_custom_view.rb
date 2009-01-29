class RefactorCustomView < ActiveRecord::Migration
  def self.up
    add_column "custom_views", "old_id", :integer # For reference to old talks system
    add_column "custom_views", "view_parameters", :string # Put all the references in a hash
    
    remove_column "custom_views", "layout"
    remove_column "custom_views", "action"
    remove_column "custom_views", "limit_numbers"
    #remove_column "custom_views", "limit"
    remove_column "custom_views", "limit_period"
    remove_column "custom_views", "seconds_before_today"
    remove_column "custom_views", "seconds_after_today"
    remove_column "custom_views", "limit_date"
    remove_column "custom_views", "start_seconds"
    remove_column "custom_views", "end_seconds"
  end

  def self.down
    remove_column "custom_views", "old_id"
    remove_column "custom_views", "view_parameters"
        
    add_column "custom_views", "layout", :string
    add_column "custom_views", "action", :string
    add_column "custom_views", "limit_numbers", :boolean, :default => false
    #add_column "custom_views", "limit", :string
    add_column "custom_views", "limit_period", :boolean, :default => false
    add_column "custom_views", "seconds_before_today", :integer
    add_column "custom_views", "seconds_after_today", :integer
    add_column "custom_views", "limit_date", :boolean, :default => false
    add_column "custom_views", "start_seconds", :datetime
    add_column "custom_views", "end_seconds", :datetime
  end
end
