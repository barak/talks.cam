# Schema as of Sat Mar 18 21:01:28 GMT 2006 (schema version 9)
#
#  id                  :integer(11)   not null
#  related_id          :integer(11)   
#  related_type        :string(255)   
#  list_id             :integer(11)   
#  score               :float         
#

class RelatedList < ActiveRecord::Base
  belongs_to :related, :polymorphic => true
  belongs_to :list
  delegate :name, :to => :list
  
  def self.update_all_lists_and_talks
    List.find(:all).each { |list| self.create_for(list) }
    Talk.find(:all).each { |talk| self.create_for(talk) }
  end
  
  def self.create_for( owner )
    owner.related_lists.clear
    List.random(3,owner.id).each do |list|
      owner.related_lists.create :list => list
    end
  end
  
end
