class AddCustomView < ActiveRecord::Migration
  def self.up
    create_table 'custom_views' do |t|
      t.column 'name',                  :string
      t.column 'user_id',               :integer
      t.column 'list_id',               :integer
      t.column 'layout',                :string
      t.column 'action',                :string
      t.column 'limit_numbers',         :boolean, :default => 0
      t.column 'limit',                 :string
      t.column 'limit_period',          :boolean, :default => 0
      t.column 'seconds_before_today',  :integer
      t.column 'seconds_after_today',   :integer
      t.column 'limit_date',            :boolean, :default => 0      
      t.column 'start_seconds',         :datetime
      t.column 'end_seconds',           :datetime
    end
  end

  def self.down
    drop_table 'custom_views'
  end
end
