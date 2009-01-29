require File.dirname(__FILE__) + '/../test_helper'

class TalkTest < Test::Unit::TestCase
  fixtures :talks, :lists, :list_talks, :list_lists, :users

  def test_find_public
    assert_equal false, Talk.find_public(:all).any? {|t| t.ex_directory? }
    assert_equal false, Talk.find_public(:all, :conditions => ['start_time >= ?',Time.now], :limit => 3).any? {|t| t.ex_directory? }
  end
  
  def test_sort_field
    assert_equal 'title', Talk.sort_field
  end
  
  def test_random_talk
    assert_equal 3, Talk.random_and_in_the_future(3).size
    number_of_future_talks = Talk.find(:all, :conditions => ['start_time > ?',Time.now]).size
    assert_equal false, Talk.random_and_in_the_future(number_of_future_talks,talks(:one).id).include?(talks(:one))
  end
  
  def test_lists
    assert_equal 1, talks(:one).lists.size
    assert_equal 1, talks(:one).lists.direct.size
  end
  
  def test_direct_lists
    lists(:two).add lists(:one)
    assert_equal 3, talks(:one).lists.size
    assert_equal 1, talks(:one).lists.direct.size
  end
  
  def test_remove_lists
    test_lists
    lists(:one).remove(talks(:one))
    assert_equal 0, talks(:one).lists(true).size
    assert_equal 0, talks(:one).lists(true).direct.size
  end
  
  def test_add_to_lists_on_create
    t = Talk.create :title => 'test four', :series => lists(:three), :venue => lists(:venue2)
    
    assert_equal 2, t.lists.size
    assert_equal 2, t.lists.direct.size
    
    assert_equal 1, lists(:three).talks(true).size
    assert_equal 1, lists(:three).talks.direct.size
    
    assert_equal 1, lists(:venue2).talks(true).size
    assert_equal 1, lists(:venue2).talks.direct.size
    
    t
  end
  
  def test_update_lists_on_update
    t = test_add_to_lists_on_create
    t.update_attributes :series => lists(:four), :venue => lists(:venue3)

    assert_equal 2, t.lists(true).size
    assert_equal 0, lists(:three).talks(true).size
    assert_equal 0, lists(:venue2).talks(true).size
    assert_equal 1, lists(:four).talks(true).size
    assert_equal 1, lists(:venue3).talks(true).size
  end
  
  def test_update_lists_on_destroy
    t = test_add_to_lists_on_create
    t.destroy

    assert_equal 2, t.lists.size
    # Have to make sure that a reload happens
    assert_equal 0, lists(:three).talks(true).size
    assert_equal 0, lists(:venue2).talks(true).size
  end
  
  def test_sort_of_delete
    talk = test_add_to_lists_on_create
    talk.sort_of_delete
    
    talk.reload
    
    assert_equal true, talk.ex_directory?
    # Remove from any lists
    assert_equal 0, talk.lists(true).size
    assert_equal 0, talk.lists.direct.size
    # But leave pointing at old venue and series
    assert_equal lists(:three), talk.series
    assert_equal lists(:venue2), talk.venue
    # Have to make sure that a reload happens
    assert_equal 0, lists(:three).talks(true).size
    assert_equal 0, lists(:venue2).talks(true).size
  end
  
  def test_aliases
    talk = talks(:one)
    assert_equal talk.name, talk.title
    assert_equal talk.details, talk.abstract
  end
  
  def test_series_name
    talk = Talk.create :title => 'test talk'
    assert_equal "", talk.series_name
    talk.series = lists(:one)
    talk.save
    assert_equal lists(:one).name, talk.series_name
  end
  
  def test_series_name_setter
    User.current = users(:seriesowner)
    talk = Talk.create! :series_name => lists(:series).name
    assert_equal(lists(:series).id, talk.series.id)
    talk = Talk.create! :series_name => 'A brand new series'
    assert series = List.find_by_name('A brand new series')
    assert_equal(series.id, talk.series.id)
    talk = Talk.create! :series_name => ""
    assert_equal(nil, talk.series)    
  end
  
  def test_venue_name
    talk = Talk.create :title => 'test talk'
    assert_equal "", talk.venue_name
    talk.venue = lists(:venue)
    talk.save
    assert_equal lists(:venue).name, talk.venue_name
  end
  
  def test_venue_name_setter
    talk = Talk.create! :venue_name => lists(:venue).name
    assert_equal(lists(:venue), talk.venue)
    talk = Talk.create! :venue_name => 'A brand new venue'
    assert venue = Venue.find_by_name('A brand new venue')
    assert_equal(venue, talk.venue)
    talk = Talk.create! :venue_name => ""
    assert_equal(nil, talk.venue)
  end
  
  def test_organiser_email
    talk = Talk.create!
    assert_equal("", talk.organiser_email)
    talk.organiser = users(:vic)
    assert_equal(users(:vic).email,talk.organiser_email)
  end
  
  def test_organiser_email_setter
    talk = Talk.create! :organiser_email => users(:vic).email
    assert_equal(users(:vic),talk.organiser)
    talk = Talk.create! :organiser_email => 'someonenew@talks.cam'
    assert user = User.find_by_email('someonenew@talks.cam')
    assert_equal(user,talk.organiser)
    talk = Talk.create! :organiser_email => ''
    assert_equal(nil, talk.organiser)
  end
  
  def test_speaker_name_and_affiliation
    talk = Talk.create!
    talk.name_of_speaker = "Tom"
    assert_equal "Tom", talk.speaker_name
    assert_equal "", talk.speaker_affiliation
    talk.name_of_speaker = "Dr. Thomas Allan Malet D'Counsell"
    assert_equal "Dr. Thomas Allan Malet D'Counsell", talk.speaker_name
    assert_equal "", talk.speaker_affiliation
    talk.name_of_speaker = "Dr. Thomas Allan Malet D'Counsell(University of Cambridge)"
    assert_equal "Dr. Thomas Allan Malet D'Counsell", talk.speaker_name
    assert_equal "University of Cambridge", talk.speaker_affiliation
    talk.name_of_speaker = "Dr. Thomas Allan Malet D'Counsell,University of Cambridge"
    assert_equal "Dr. Thomas Allan Malet D'Counsell", talk.speaker_name
    assert_equal "University of Cambridge", talk.speaker_affiliation
  end
    
  def test_speaker_email
    talk = Talk.create!
    assert_equal("", talk.speaker_email)
    talk.speaker = users(:vic)
    assert_equal(users(:vic).email,talk.speaker_email)
  end
  
  def test_speaker_email_setter
    talk = Talk.create! :speaker_email => users(:vic).email
    assert_equal(users(:vic),talk.speaker)
    talk = Talk.create! :speaker_email => 'someonenew@talks.cam'
    assert user = User.find_by_email('someonenew@talks.cam')
    assert_equal(user,talk.speaker)
    talk = Talk.create! :speaker_email => ''
    assert_equal(nil, talk.speaker)
    
    talk = Talk.create! 
    talk.speaker_email = nil
    assert_equal(nil, talk.speaker)
    
    # Check that the speaker's name and affiliation get set correctly
    talk = Talk.create! :name_of_speaker => "Prof. Jim D'Helen (U. of C.B.C.)", :speaker_email => 'jim.helen@talks.cam.ac.uk'
    assert user = User.find_by_email('jim.helen@talks.cam.ac.uk')
    assert_equal "Prof. Jim D'Helen", user.name
    assert_equal "U. of C.B.C.", user.affiliation
  end
  
  def a_time
    Time.local(2007,02,01,9,14)
  end
  
  def test_date_string
    talk = Talk.create! :start_time => a_time
    assert_equal("2007/02/01", talk.date_string)
    talk.date_string = "blah blah blah"
    assert_equal("blah blah blah", talk.date_string)
  end
  
  def test_start_time_string
    talk = Talk.create! :start_time => a_time
    assert_equal("09:14", talk.start_time_string)
    talk.start_time_string = "blah blah blah"
    assert_equal("blah blah blah", talk.start_time_string)
  end
  
  def test_end_time_string
    talk = Talk.create! :end_time => a_time
    assert_equal("09:14", talk.end_time_string)
    talk.end_time_string = "blah blah blah"
    assert_equal("blah blah blah", talk.end_time_string)
  end
  
  def test_checks_date_start_and_end_strings_valid
  	# Date must be YYYY/MM/DD and parseable, or blank
    talk = Talk.create :date_string => "01/02/2007"
    assert talk.errors.invalid?(:date_string)
    talk = Talk.create :date_string => ""
    assert !talk.errors.invalid?(:date_string)
    talk = Talk.create :date_string => "2007/12/20"
    assert !talk.errors.invalid?(:date_string)
    talk = Talk.create :date_string => "2007/12/33"
    assert talk.errors.invalid?(:date_string)
    talk = Talk.create :date_string => "2007/12/0"
    assert talk.errors.invalid?(:date_string)
    talk = Talk.create :date_string => "2007/13/20"
    assert talk.errors.invalid?(:date_string)
    talk = Talk.create :date_string => "2007/0/20"
    assert talk.errors.invalid?(:date_string)
    
  	# Time strings must be HH:MM and parseable, or blank
    talk = Talk.create :start_time_string => "09-40"
    assert talk.errors.invalid?(:start_time_string)
    talk = Talk.create :start_time_string => "09:40"
    assert !talk.errors.invalid?(:start_time_string)
    talk = Talk.create :start_time_string => "25:36"
    assert talk.errors.invalid?(:start_time_string)
    talk = Talk.create :start_time_string => "20:65"
    assert talk.errors.invalid?(:start_time_string)

    talk = Talk.create :end_time_string => "09-40"
    assert talk.errors.invalid?(:end_time_string)
    talk = Talk.create :end_time_string => "09:40"
    assert !talk.errors.invalid?(:end_time_string)
    talk = Talk.create :end_time_string => "25:36"
    assert talk.errors.invalid?(:end_time_string)
    talk = Talk.create :end_time_string => "20:65"
    assert talk.errors.invalid?(:end_time_string)
  end
  
  def test_update_start_and_end_time_from_strings
    talk = Talk.create! :date_string => "2007/02/01", :start_time_string => '09:14', :end_time_string => '10:14'
    assert_equal(a_time, talk.start_time)
    assert_equal(a_time+1.hour, talk.end_time)
  end

  def test_send_an_email_to_the_speaker
     Mailer.deliveries.clear
     speaker = User.create! :email => 'speaker@talks.cam', :name => 'speaker'
     organiser = User.create! :email => 'organiser@talks.cam', :name => 'organiser'
     talk = Talk.create! :speaker => speaker, :organiser => organiser, :start_time => Time.now, :end_time => Time.now+1.hour, :send_speaker_email => '1', :series => lists(:one)
     mail = Mailer.deliveries.find { |mail| mail.to[0] == speaker.email && mail.subject == 'Giving a talk in Cambridge' }
     assert mail
     assert_equal mail.cc[0], organiser.email
     mail = Mailer.deliveries.find { |mail| mail.to[0] == speaker.email && mail.subject == 'Your talks.cam password' }
     assert mail
  end
  
  def test_term
    lent = [ Time.local( 2005,1,1), Time.local(2005,3,31) ]
    assert_equal lent, Talk.create( :start_time => lent.first ).term
    assert_equal lent, Talk.create( :start_time => lent.first + 10.days ).term
    assert_equal lent, Talk.create( :start_time => lent.last ).term
    
    # Easter
    easter = [ Time.local( 2005,4,1), Time.local(2005,6,30) ]
    assert_equal easter, Talk.create( :start_time => easter.first ).term
    assert_equal easter, Talk.create( :start_time => easter.first + 10.days ).term
    assert_equal easter, Talk.create( :start_time => easter.last ).term
    
    # Vacation
    vacation = [ Time.local( 2005,7,1), Time.local(2005,9,30) ]
    assert_equal vacation, Talk.create( :start_time => vacation.first ).term
    assert_equal vacation, Talk.create( :start_time => vacation.first + 10.days ).term
    assert_equal vacation, Talk.create( :start_time => vacation.last ).term
    
    # Michaelmas
    michaelmas = [ Time.local( 2005,10,1), Time.local(2005,12,31) ]
    assert_equal michaelmas, Talk.create( :start_time => michaelmas.first ).term
    assert_equal michaelmas, Talk.create( :start_time => michaelmas.first + 10.days ).term
    assert_equal michaelmas, Talk.create( :start_time => michaelmas.last ).term
  end
  
  def test_xss_prevention
    talk = Talk.new
    fields = %w{title special_message name_of_speaker }
    fields.each {|field| talk.send("#{field}=","Test <tags> are </tags> <escaped/>") }
    talk.save
    fields.each do |field|
      assert_equal "Test &lt;tags&gt; are &lt;/tags&gt; &lt;escaped/&gt;", talk.send(field),"Field: #{field}"
    end
    
    talk.title = "Test &lt;tags&gt; are &lt;/tags&gt; &lt;escaped/&gt;"
    talk.save
    assert_equal "Test &lt;tags&gt; are &lt;/tags&gt; &lt;escaped/&gt;", talk.title
    
    talk.abstract = "A <hr/> <br/> <a href=\"javascript:alert('gotcha')\" onclick=\"attack()\">Hello</a>"
    talk.save
    assert_equal "A <hr/> <br/> <a href=\"javascript:alert('gotcha')\" onclick=\"attack()\">Hello</a>", talk.abstract
    assert_equal "<p>A   <br> <a href=\"\">Hello</a></p>", talk.abstract_filtered
    
  end
  
  def test_utf8_cleaning
    talk = Talk.new
    fields = %w{title special_message name_of_speaker abstract }
    fields.each {|field| talk.send("#{field}=","\226 that is,€ it is") }
    talk.save
    fields.each do |field|
      assert_equal " that is,€ it is", talk.send(field),"Field: #{field}"
    end
  end
  
  # Assumes we are in a British Time Zone
  # Checks handles summer time conversion correctly
  def test_set_time_slot
    talk = Talk.new
    talk.set_time_slot '2006/11/1', '20:00','21:00'
    assert_equal "Wed Nov 01 20:00:00 UTC 2006", talk.start_time.getgm.to_s
    talk.set_time_slot '2006/10/1', '20:00','21:00'
    assert_equal "Sun Oct 01 19:00:00 UTC 2006", talk.start_time.getgm.to_s
  end

  def test_ability_to_add_an_image
   talk = Talk.create!(:title => 'a talk with a pretty picture')
    # As an image object
    talk.image = an_image
    assert_kind_of Image, talk.image
    # As data
    image_file do |file|
      talk.image = file
    end
    assert_kind_of Image, talk.image
    # Leave original image if try and set with empty field
    current_image = talk.image
    talk.image = ""
    assert_equal current_image, talk.image
  end
  
  def an_image
    image_file do |file|
      image = Image.create :data => file
    end
  end
  
  def image_file
    File.open(gif_image,'r') do |f|
      f.extend FileCGICompatability
      yield f
    end
  end
  
end
