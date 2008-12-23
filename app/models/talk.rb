class Talk < ActiveRecord::Base
  
  def Talk.find_public(*args)
    Talk.with_scope(:find => {:conditions => "ex_directory = 0 AND title != 'Title to be confirmed'"}) do
      Talk.find(*args)
    end
  end
  
  def Talk.random_and_in_the_future(number_of_talks_to_find = 1, exclude_talk_id = 0 )
    Talk.find_public(:all,  :order => 'RAND()', 
                            :limit => number_of_talks_to_find, 
                            :conditions => ["id != ? AND start_time > ?",exclude_talk_id,Time.now])
  end
  
  def Talk.sort_field; 'title' end
    
  include TextileToHtml # To convert abstract
  include Relatable # To have related lists and talks
  include PreventScriptAttacks # Try and prevent xss attacks
  include CleanUtf # To try and prevent any malformed utf getting in
  def exclude_from_xss_checks; %w{ abstract abstract_filtered } end # They go through textile filter anyway
  
  # Link tables
  has_many :list_talks, :dependent => :destroy, :extend => FindDirectExtension
  
  # Interesting relationships
  belongs_to  :speaker, :foreign_key => 'speaker_id', :class_name => 'User'
  belongs_to  :organiser, :foreign_key => 'organiser_id', :class_name => 'User'
  belongs_to  :series, :class_name => 'List', :foreign_key => 'series_id'
  belongs_to  :venue, :class_name => 'List', :foreign_key => 'venue_id'
  has_many    :lists, :through => :list_talks, :extend => FindDirectExtension 
   
  # This is to allow a custom image to be loaded
  include BelongsToImage
  
  # Validations
  validates_format_of :date_string, :with => %r{\d\d\d\d/\d+/\d+}, :allow_nil => true
  validates_format_of :start_time_string, :with => %r{\d+:\d+}, :allow_nil => true
  validates_format_of :end_time_string, :with => %r{\d+:\d+}, :allow_nil => true
  
  before_save :update_html_for_abstract
  before_save :check_if_venue_or_series_changed
  after_validation :update_start_and_end_times_from_strings
  after_save  :add_to_lists
  after_save  :possibly_send_the_speaker_an_email

  def sort_of_delete
    self.ex_directory = true
    self.special_message = "This talk has been canceled/deleted"
    self.save
    
    ListTalk.delete_all ['talk_id = ?',id]
    true # So can continue
  end
  
  def check_if_venue_or_series_changed
    return @new_series_and_venue = true if new_record?
    old_talk = Talk.find(id)
    @old_venue = old_talk.venue unless self.venue_id == old_talk.venue_id
    @old_series = old_talk.series unless self.series_id == old_talk.series_id
  end
  
  # Make sure the talk is part of the venue and series lists
  def add_to_lists
    series.add(self) if (series && @new_series_and_venue || @old_series)
    venue.add(self) if (venue && @new_series_and_venue || @old_venue)
    @old_series.remove(self) if @old_series
    @old_venue.remove(self) if @old_venue
  end
  
  # To allow duck-typing with a list
  def name; title end
  def details; abstract end
  
  # Short cut to the series name
  def series_name
    series ? series.name : ""
  end
  
  def series_name=(new_series_name)
    self.series = new_series_name.blank? ? nil : List.find_or_create_by_name_while_checking_management(new_series_name)
  end
  
  # Short cut to the venue name
  def venue_name
    venue ? venue.name : ""
  end
  
  def venue_name=(new_venue_name)
    self.venue = new_venue_name.blank? ? nil : Venue.find_or_create_by_name(new_venue_name)
  end
  
  # Short cut to organiser email
  def organiser_email
    organiser ? organiser.email : ""
  end
  
  def organiser_email=(email)
    self.organiser = email.blank? ? nil : User.find_or_create_by_email(email)
  end
  
  # Tries to figure these out from the name of speaker field if no speaker given
  def speaker_name
    return "" unless self.name_of_speaker
    self.name_of_speaker[/^\s*([^,(]*)/,1].strip
  end
  
  def speaker_affiliation
    return "" unless self.name_of_speaker
    self.name_of_speaker[/[,(]([^)]*)[)]?/,1] || ""
  end
  
  # Short cut to speaker email
  def speaker_email
    speaker ? speaker.email : ""
  end
  
  def speaker_email=(email)
    return if email.blank?
    self.speaker = User.find_or_create_by_email(email)
    return if speaker.name && speaker.affiliation
    speaker.name ||= speaker_name 
    speaker.affiliation ||= speaker_affiliation
    speaker.save
  end
  
  # For security
  def editable?
    return false unless User.current
    User.current.administrator? or
    (speaker == User.current ) or
    (series.users.include? User.current )
  end
    
  # This provides the talks start and end time in 
  # a format convenient for using in the create talk
  # feature
  def time_slot
    return nil unless start_time && end_time
    [ sprintf("%d:%02d", start_time.hour, start_time.min),
      sprintf("%d:%02d", end_time.hour, end_time.min) ]
  end
  
  def set_time_slot( date, start, finish )
    year,month, day = date.split('/')
    start_hour, start_minute = start.split(':')
    end_hour, end_minute = finish.split(':')
    self.start_time = Time.local year, month, day, start_hour, start_minute
    self.end_time = Time.local year, month, day, end_hour, end_minute
  end
  
  def date
    return nil unless start_time
    start_time.to_date
  end
  
  def date_string
    @date_string || (start_time && start_time.strftime('%Y/%m/%d'))
  end
  attr_writer :date_string
  
  def start_time_string
    @start_time_string || (start_time && start_time.strftime('%H:%M'))
  end
  attr_writer :start_time_string
  
  def end_time_string
    @end_time_string || (end_time && end_time.strftime('%H:%M'))
  end
  attr_writer :end_time_string
  
  def update_start_and_end_times_from_strings
    #Don't try to run this unless we have sensible strings to work with
    return unless @start_time_string && @end_time_string && @date_string && errors.count==0
    year,month, day = date_string.split('/')
    start_hour, start_minute = start_time_string.split(':')
    end_hour, end_minute = end_time_string.split(':')
    self.start_time = Time.local year, month, day, start_hour, start_minute
    self.end_time = Time.local year, month, day, end_hour, end_minute
    true
  end
  
  attr_accessor :send_speaker_email
  
  def possibly_send_the_speaker_an_email
    return unless send_speaker_email == '1'
    return true unless speaker_email && speaker_email =~ /.*?@.*?\..*/
    Mailer.deliver_speaker_invite( speaker, self )
    speaker.send_password
  end
  
  # FIXME: Refactor with the code in the show controller
  def term
    return nil unless start_time
    case start_time.mon
     when 1..3 # Lent term
       return month_range( start_time.year, 1, 3 )
     when 4..6 # Easter term
       return month_range( start_time.year, 4, 6 )
     when 7..9 # Long vac.
       return month_range( start_time.year, 7, 9 )
     when 10..12 # Michaelmas term
       return month_range( start_time.year, 10, 12 )
     end
  end
    
  # This is used to transform the textile in abstract into redcloth
  def update_html_for_abstract
    return unless abstract
    self.abstract_filtered = textile_to_html( abstract )
  end
  
    def to_ics
      [
        'BEGIN:VEVENT',
        "CATEGORIES:#{series && series.name && series.name.to_ics}",
        "SUMMARY:#{"#{title} - #{name_of_speaker}".to_ics}",
        "DTSTART:#{start_time.getgm.to_s(:ics)}",
        "DTEND:#{end_time.getgm.to_s(:ics)}",
        "UID:TALK#{id}AT#{ActionController::Base.asset_host}",
        "URL:#{ActionController::Base.asset_host}/talk/index/#{id}",
        "DESCRIPTION:#{abstract && abstract.to_ics}",
        "LOCATION:#{venue && venue.name && venue.name.to_ics}",
        "CONTACT:#{organiser && organiser.name && organiser.name.to_ics}",
        "END:VEVENT"
      ].join("\r\n")
    end
  
  private
  
  # FIXME: Refactor with the code in the show controller
	def month_range( year, start_month, end_month )
	 return Time.local( year, start_month ).at_beginning_of_month, Time.local(year,end_month).at_end_of_month
	end
  
end

