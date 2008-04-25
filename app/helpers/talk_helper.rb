module TalkHelper
  
  def update_field(field,title,value=title)
    link_to_function title, "setField('#{field}','#{value}')"
  end
  
  def set_user_details( user )
    link_to_function "#{user.name} (#{user.affiliation}) - #{user.email}","setSpeaker('#{user.name} (#{user.affiliation})','#{user.email}')"
  end
  
  def body_class
    'list talk'
  end
  
  def add_talk_to_list_link
    if User.current && User.current.has_added_to_list?( @talk )
      if User.current.only_personal_list?
        link_to 'Remove from your list(s)', include_talk_url(:action => 'destroy', :child => @talk)
      else
        link_to 'Add/Remove from your list(s)', include_talk_url(:action => 'create', :child => @talk)
      end
    else
      link_to 'Add to your list(s)',include_talk_url(:action => 'create', :child => @talk)
    end
  end
end
