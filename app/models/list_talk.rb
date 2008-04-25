# TODO: Refactor this to use child rather than talk (or at least alias the two) and then, perhaps merge into ListList
class ListTalk < ActiveRecord::Base
  
  include CommonLinkMethods
  
  belongs_to :list
  belongs_to :talk
  
  def after_create
    add_dependent_talk_links if direct?
    true # Permit other callbacks to occur
  end
  
  def after_destroy
    ListTalk.delete_all "dependency LIKE '% t#{id} %'"
    true # Permit other callbacks to occur
  end

  def to_dependency_string
    direct? ? "#{dependency} t#{id}" : "#{dependency}"
  end  

  def to_s
    "t#{id}: #{list.id} -> t#{talk.id} depends_on: #{dependency}"
  end
  
  private
    
  def add_dependent_talk_links
    parents_of_parent.each do |parent_link|
      create_talk_link  parent_link.list, talk, parent_link
    end
  end
  
end
