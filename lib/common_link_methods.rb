# This is included by list_list and list_talk
# to share the common methods
# could have subclassed instead, but
# this felt better
module CommonLinkMethods
  # Is a direct entry if not added by any other list
  def direct?
    !dependency
  end
  
  # For security
  def editable?
    return false unless User.current
    User.current.administrator? or
    (list.users.include? User.current )
  end
  
  # Because had problems pattern matching on some sql versions
  # Surround the dependency field with spaces and fullstops like . so .
  def dependency=(value)
    self[:dependency] = ". #{value} .".gsub(/ +/,' ')
  end
  
  def dependency
    return nil unless self[:dependency]
    self[:dependency][%r{^\. (.*) \.$},1]
  end
  
  def parents_of_parent
    @parents_of_parent ||= ListList.find(:all, :conditions => {:child_id => list.id})
  end
  
  def create_talk_link(list,talk,*dependent_links)
    dependency = dependent_links.map {|link| link.to_dependency_string }.join(' ') + " #{id}"
    ListTalk.create :list => list, :talk => talk, :dependency => dependency    
  end
end