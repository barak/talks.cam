# This keeps a track of the 'tell-a-friend' type requests
class Tickle < ActiveRecord::Base
  belongs_to :about, :polymorphic => true
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  
  before_validation :update_sender_details_from_sender_object
  after_create :send_tickle_to_recipient
  
  validates_format_of :sender_email, :with => /.*?@.*?\..*/
  validates_format_of :recipient_email, :with => /.*?@.*?\..*/
  validates_length_of :sender_name, :minimum => 2
  
  def validate
    if Tickle.find_by_recipient_email_and_about_id_and_about_type(recipient_email,about_id,about_type)
      errors.add(:recipient_email,"has already been sent a message about this.")
    end
    if sender_ip && Tickle.find(:all,:conditions => ['created_at > ? AND sender_ip = ?',1.hour.ago, sender_ip] ).size >= 10
      errors.add(:sender_ip,"has already sent more than 10 messages in the past hour")
    end
  end

  def send_tickle_to_recipient
    case about
    when Talk; Mailer.deliver_talk_tickle( self )
    when List; Mailer.deliver_list_tickle( self )
    end
  end
  
  def update_sender_details_from_sender_object
    return true unless sender
    self.sender_email = sender.email
    self.sender_name = sender.name
    true
  end
  
end
