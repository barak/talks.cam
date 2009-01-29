class User < ActiveRecord::Base

  # This is used as an easier way of accessing who is the current user
  def User.current=(u)
    Thread.current[:user] = u
  end
  
  def User.current
    Thread.current[:user]
  end
  
  def User.search(search_term)
    return [] unless search_term && !search_term.empty?
    User.find_public(:all, :conditions => ["(name LIKE :search OR affiliation LIKE :search OR email LIKE :search)",{:search => "%#{search_term.strip}%"}], :order => 'name ASC' )
  end
  
  def User.find_public(*args)
    User.with_scope :find => { :conditions => ["ex_directory = 0"] } do
      User.find(*args)
    end
  end
  
  def User.sort_field; 'name_in_sort_order' end
  
  def User.find_or_create_by_crsid( crsid )
    user = User.find_by_crsid crsid
    return user if user
    # No email, so create
    User.create! :crsid => crsid, :email => "#{crsid}@cam.ac.uk", :affiliation => 'University of Cambridge'
  end
  
  # Lists that the user is mailed about
  has_many :email_subscriptions
  
  # Lists that this user manages
  has_many :list_users
  has_many :lists, :through => :list_users
  
  # Talks that this user speaks on
  has_many :talks, :foreign_key => 'speaker_id', :order => 'start_time DESC'
  
  # Talks that this user organises
  has_many :talks_organised, :class_name => "Talk", :foreign_key => 'organiser_id', :conditions => "ex_directory != 1", :order => 'start_time DESC'

  validates_uniqueness_of :email, :message => 'address is already registered on the system'
    
  # Life cycle actions
  before_save :update_crsid_from_email
  before_save :update_name_in_sort_order
  before_create :randomize_password
  after_create :create_personal_list
  after_create :send_password_if_required
  
  # Try and prevent xss attacks
  include PreventScriptAttacks
  include CleanUtf # To try and prevent any malformed utf getting in
  
  # Has a connected image
  include BelongsToImage
  
  def editable?
    return false unless User.current
    ( User.current == self ) or ( User.current.administrator? )
  end
  
  def update_crsid_from_email
    return unless email =~ /^([a-z0-9]+)@cam.ac.uk$/i
    self.crsid = $1
  end
  
  def update_name_in_sort_order
    if name =~ /^\s*((.*) )?(.*)\s*$/
      self.name_in_sort_order = $2 ? "#{$3}, #{$2}" : $3
    else
      self.name_in_sort_order = ""
    end
  end
  
  def self.update_ex_directory_status
    User.find(:all).each { |u| u.update_ex_directory_status }
  end
  
  def update_ex_directory_status
    new_status = lists.find(:all,:conditions => ['ex_directory = 0']).empty? && talks.empty? && talks_organised.empty?
    update_attribute(:ex_directory,new_status) unless self.ex_directory? == new_status
    new_status
  end
  
  # Only accept new passwords when some confirmation is done
  attr_accessor :password_confirmation
  attr_accessor :existing_password
  attr_accessor :old_password
  attr_accessor :changing_password
  
  def password=(new_password)
    self.changing_password = true
    self.old_password = password
    write_attribute(:password, new_password)
  end
  
  def validate
    if changing_password
      errors.add(:existing_password,"must match your existing password.") unless existing_password == old_password
      errors.add(:password_confirmation,"must match your new password.") unless password_confirmation == password
    end
  end
  
  # ten digit password
  def randomize_password( size = 10 )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpassword = ""
    1.upto(size) { |i| newpassword << chars[rand(chars.size-1)] }
    write_attribute(:password, newpassword)
  end
  
  # After creating a user, create their personal list
  def create_personal_list
    list_name = 
      if self.name; "#{self.name}'s list"
      elsif self.crsid; "#{self.crsid}'s list"
      else; "Your personal list"
    end
    list = List.create! :name => list_name, :details => "A personal list of talks.", :ex_directory => true
    self.lists << list
  end
  
  # After creating a user, send them an e-mail with their password if this is set
  attr_accessor :send_email
  
  def send_password_if_required
    send_password if send_email
  end
  
  def send_password
    email = Mailer.create_password( self )
    Mailer.deliver email
  end
  
  def personal_list
    lists.first
  end
  
  def only_personal_list?
    (lists.size == 1)
  end
  
  def send_emails_about_personal_list
    EmailSubscription.find_by_list_id_and_user_id( personal_list, id ) ? true : false
  end
  
  def send_emails_about_personal_list=(send_email)
    if send_email == '1' && !send_emails_about_personal_list
      email_subscriptions.create :list => personal_list
    elsif send_email == '0' && send_emails_about_personal_list
      EmailSubscription.find_by_list_id_and_user_id( personal_list, id ).destroy
    end
  end
  
  # Subscribe by email to a lsit
  def subscribe_to_list( list )
    email_subscriptions.create :list => list
  end
  
  def has_added_to_list?( thing )
    case thing
    when List
      lists.detect { |users_list| users_list.children.direct.include?( thing ) }
    when Talk
      lists.detect { |users_list| users_list.talks.direct.include?( thing )}
    end
  end
  
  # This is used upon login to check whether the user should be asked to fill in more detail
  def needs_an_edit?
    return last_login ? false : true
  end
  
end
