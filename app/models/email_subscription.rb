# Schema as of Sat Mar 18 21:01:28 GMT 2006 (schema version 9)
#
#  id                  :integer(11)   not null
#  user_id             :integer(11)   
#  list_id             :integer(11)   
#

class EmailSubscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :list

  validates_presence_of :user
  validates_presence_of :list
  
  # For security
   def editable?
     return false unless User.current
     User.current.administrator? or
     (user == User.current )
   end
end
