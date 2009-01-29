class ListUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :list
  
  def user_email=( email_address )
    self.user = User.find_or_create_by_email(email_address)
  end
  
  def user_email
    return "" unless user
    user.email
  end
  
end
