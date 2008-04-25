# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def subscribe_by_email_link
   if User.current && ( sub = EmailSubscription.find_by_list_id_and_user_id( @list.id, User.current.id ) )
     link_to 'Halt your e-mail reminders', reminder_url(:action => 'destroy', :id => sub.id )
   else
     link_to 'Send you e-mail reminders', reminder_url(:action => 'create', :list => @list.id )
   end
  end
  
  def show_flash
    [:error, :warning, :confirm].map { |name| flash[name] ? "<div class=\"#{name}\">#{flash[name]}</div>" : "" }.join 
  end
  
  def document(name, include_arrow = false, link_text = name )
    if include_arrow
      link_to link_text+arrow, document_url(:name => name ), {:class => 'click'}
    else
      link_to link_text, document_url(:name => name ), {:class => 'click'}
    end
  end
  
  def add_list_to_list_link
    if User.current && User.current.has_added_to_list?( @list )
      if User.current.only_personal_list?
        link_to 'Remove from your list(s)', include_list_url(:action => 'destroy', :child => @list)
      else
        link_to 'Add/Remove from your list(s)', include_list_url(:action => 'create', :child => @list)
      end
    else
      link_to 'Add to your list(s)', include_list_url(:action => 'create', :child => @list)
    end
  end
  
  def format_time_of_talk( talk )
    return "Time not fully specified" unless talk.start_time && talk.end_time
     if talk.start_time.year == talk.end_time.year &&
        talk.start_time.month == talk.end_time.month &&
        talk.start_time.day == talk.end_time.day
        "<abbr style='border:none' class='dtstart' title='#{time_to_ical talk.start_time}'>#{talk.start_time.strftime('%A %d %B %Y, %H:%M')}</abbr>-<abbr style='border:none' class='dtend' title='#{time_to_ical talk.end_time}'>#{talk.end_time.strftime('%H:%M')}</abbr>"
     else
       "<abbr style='border:none' class='dtstart' title='#{time_to_ical talk.start_time}'>#{talk.start_time.strftime('%A %d %B %Y, %H:%M')}</abbr>-<abbr style='border:none' class='dtend' title='#{time_to_ical talk.end_time}'>#{talk.end_time.strftime('%A %d %B, %H:%M')}</abbr>"
     end
   end
   
   def format_hours_of_talk( talk, abbr = true )
     return "Time not fully specified" unless talk.start_time && talk.end_time
     if abbr
       "<abbr style='border:none' class='dtstart' title='#{time_to_ical talk.start_time}'>#{talk.start_time.strftime('%H:%M')}</abbr>-<abbr style='border:none' class='dtend' title='1#{time_to_ical talk.end_time}'>#{talk.end_time.strftime('%H:%M')}</abbr>"
     else
       "#{talk.start_time.strftime('%H:%M')}-#{talk.end_time.strftime('%H:%M')}"
     end
   end
   
   def arrow(alttext = 'details')
     image_tag 'redarrow.gif', :alt => alttext
   end
   
   def logo( object, size = :small ) 
      case object
      when Talk
        if object.image_id?
          logo_tag( object, size )
        elsif object.speaker
          logo object.speaker, size
        elsif object.series
          logo object.series, size
        else
          ""
        end
      when List
        if object.image_id?
          logo_tag object, size
        else
          ""
        end
      when User
        if object.image_id?
          logo_tag object, size
        else
          ""
        end
      end
   end
   
   def logo_tag( object, size = :small )
    return "" unless object.image_id?
    url = case size
    when :small; picture_url(:id => object.image_id, :geometry => '32x32' )
    when :medium; picture_url(:id => object.image_id, :geometry => '128x128' )
    else; picture_url(:id => object.image_id, :geometry => size )
    end
    image_tag url, :alt => "#{object} logo", :class => 'logo'
   end
   
   def cluster_by_date( talks ) 
     h = Hash.new
     talks.each do |talk|
       h[ talk.start_time.to_date ] ||= []
       h[ talk.start_time.to_date ] << talk
     end
     return h.sort
   end
   
   def link_talk( talk )
     return "No talk" unless talk
     link_to talk.title, talk_url(:id => talk), :class => 'click link'
   end
   
   def link_list( list )
     return "No list" unless list
      link_to list.name, list_url(:id => list)
   end
   
   def link_user( user )
     return 'nobody' unless user
     link_to user.name || user.email[/[^@]*/], user_url(:id => user)
   end
   
   def page_title
      ['talks.cam',@list && @list.name, @talk && @talk.title, @user && @user.name ].compact.join(' : ')
   end
   
   def javascripts
     ["calendar.js","calendar-setup.js","calendar-en.js","behaviour.js",:defaults].map do |javascript|
       javascript_include_tag javascript
     end.join "\n"
   end

   def stylesheets
     ['talks-screen','calendar-blue'].map do |stylesheet|
       stylesheet_link_tag stylesheet, :media => 'all'
     end.join "\n"
   end
   
   def breadcrumbs
    return unless @list || @talk || @user
    if @list && @list.id
      "&nbsp;&gt;&nbsp;#{link_list(@list)}"
    elsif @talk && @talk.id
      "&nbsp;&gt;&nbsp;#{link_list(@talk.series)}&nbsp;&gt;&nbsp;#{link_talk(@talk)}"
    elsif @user && @user.id
      "&nbsp;&gt;&nbsp;#{link_user(@user)}"
    end
   end
   
   def body_class
    'application'
   end
   
   # FIXME: Refactor this somewhere else
   # Code borrowed from icalendar gem
   def time_to_ical( time )
       s = ""

       # 4 digit year
       s << time.year.to_s

       # Double digit month
       s << "0" unless time.month > 9 
       s << time.month.to_s

       # Double digit day
       s << "0" unless time.day > 9 
       s << time.day.to_s

       s << "T"

       # Double digit hour
       s << "0" unless time.hour > 9 
       s << time.hour.to_s

       # Double digit minute
       s << "0" unless time.min > 9 
       s << time.min.to_s

       # Double digit second
       s << "0" unless time.sec > 9 
       s << time.sec.to_s

       # UTC time gets a Z suffix
       #s << "Z"
      
       s
     end
     
     def escape_for_ical( string )
       [ ["\\","\\\\\\"],[/\r\n/,'\n' ],[/\n/,'\n' ], [',','\,'],[';','\;'] ].each do |substition|
         string = string.gsub *substition
       end
       string
     end
end
