class CreateImages < ActiveRecord::Migration
  def self.up
     create_table :images, :force => true do |t|
       t.column :data, :binary, :size => 10000000, :null => false
       t.column :created_at, :datetime
     end
     execute "ALTER TABLE `images` MODIFY `data` MEDIUMBLOB"
   end

  def self.down
    drop_table :images
  end
end
