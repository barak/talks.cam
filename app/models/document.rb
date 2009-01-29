# Schema as of Sat Mar 18 21:01:28 GMT 2006 (schema version 9)
#
#  id                  :integer(11)   not null
#  name                :string(255)   
#  body                :text          
#  html                :text          
#  version             :integer(11)   
#  user_id             :integer(11)   
#  administrator_only  :boolean(1)    
#

class Document < ActiveRecord::Base
  
  include TextileToHtml # To convert details
  include PreventScriptAttacks # Try and prevent xss attacks
  def exclude_from_xss_checks; %w{ body html } end # They go through textile filter anyway
  include CleanUtf # To try and prevent any malformed utf getting in
    
  acts_as_versioned
  validates_uniqueness_of :name
  belongs_to :user
  
  PAGE_LINK = /\[\[([^\]|]*)[|]?([^\]]*)\]\]/
  
  before_save :update_html
  
  def can_edit?
    return true unless administrator_only?
    User.current.administrator?
  end
  
  def update_html
    self.name = self.name.underscore
    return true unless body
    self.user = User.current
    linked_body = body.gsub(PAGE_LINK) { link( $1, $2 ) }
    self.html = textile_to_html( linked_body )
  end
  
  def link( link_name, link_text )
    link_text = link_name if link_text.empty?
    "<a href='/document/#{link_name.strip}'>#{link_text.strip}</a>"
  end
  
end
