class ListList < ActiveRecord::Base

  include CommonLinkMethods
  
  belongs_to :list
  belongs_to :child, :class_name => 'List', :foreign_key => 'child_id'
  
  def validate
    return unless direct?
    errors.add_to_base "Please don't add a list to itself" if self_referential?
    errors.add_to_base "Adding this would create a circular loop" if circular?
  end
  
  def after_create
    return true unless direct?
    add_children_of_child_to_parent
    add_child_to_parents_of_parent
    add_children_of_child_to_parents_of_parent
    add_talks_of_child
    true # Permit other callbacks to occur
  end
   
  def after_destroy
    ListList.delete_all "dependency LIKE '% #{id} %'"
    ListTalk.delete_all "dependency LIKE '% #{id} %'"
    true # Permit other callbacks to occur
  end

  def to_dependency_string
    direct? ? "#{dependency} #{id}" : "#{dependency}"
  end

  def to_s
    "#{id}: #{list.id} -> #{child.id} depends_on: #{dependency}"
  end
  
  private
  
  def create_link(parent,child,*dependent_links)
    dependency = dependent_links.map {|link| link.to_dependency_string }.join(' ') + " #{id}"
    ListList.create :list => parent, :child => child, :dependency => dependency
  end
  
  # Iterate through the children of the linked list, and add its dependent links
  def add_children_of_child_to_parent
    children_of_child.each do |child_link|
      create_link list, child_link.child, child_link
    end
  end

  # Add this link to all the parents
  def add_child_to_parents_of_parent
    parents_of_parent.each do |parent_link|
      create_link parent_link.list, child, parent_link
    end
  end

   # Add children of child to parents of parent
  def add_children_of_child_to_parents_of_parent
    parents_of_parent.each do |parent_link|
      children_of_child.each do |child_link|
        create_link parent_link.list, child_link.child, parent_link, child_link
      end
    end
  end

  # parents_of_parent is in CommonLinkMethods

  def children_of_child
    @children_of_child ||= ListList.find(:all, :conditions => {:list_id => child.id })
  end  

  def add_talks_of_child
    talks_of_child.each do |talk_link|
      create_talk_link list, talk_link.talk, talk_link
    end
    parents_of_parent.each do |parent_link|
      talks_of_child.each do |talk_link|
        create_talk_link parent_link.list, talk_link.talk, parent_link, talk_link
      end
    end
  end
  
  def talks_of_child
    @talks_of_child ||= ListTalk.find(:all, :conditions => {:list_id => child.id} )
  end
  
  def self_referential?
    list_id == child_id
  end
  
  def circular?
    ListList.find_by_list_id_and_child_id(child_id,list_id) ? true : false
  end
end
