# This is used to extend the has_many :through List_lists or List_child
# to find the direct children / parents
module FindDirectExtension
  
  def direct
    find :all, :conditions => 'dependency IS NULL'
  end
end