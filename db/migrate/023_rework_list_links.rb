class ReworkListLinks < ActiveRecord::Migration
  def self.up
    ListList.delete_all "dependency is not null"
    ListTalk.delete_all "dependency is not null"
    ListList.find(:all).each { |list_list| list_list.after_create }
  end

  def self.down
  end
end
