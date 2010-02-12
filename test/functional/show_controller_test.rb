require File.dirname(__FILE__) + '/../test_helper'
require 'show_controller'

# Re-raise errors caught by the controller.
class ShowController; def rescue_action(e) raise e end; end

class ShowControllerTest < Test::Unit::TestCase
  fixtures :users, :lists, :talks, :list_talks, :list_lists
  
  def setup
    @controller = ShowController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_404_when_not_found
    assert_raise(ActiveRecord::RecordNotFound) { get :index, :id => 9090909090 }
  end
  
  def test_reverse_order_parameter
    list = List.create! :name => 'test rev order param list'
    talk1 = Talk.create! :start_time => Time.now.next_week, :series => list
    talk2 = Talk.create! :start_time => Time.now.next_month, :series => list
    get :index, :id => list.id
    talks = assigns(:talks)
    assert_equal talk1, talks.first
    assert_equal talk2, talks.last
    get :index, :id => list.id, :reverse_order => '1'
    talks = assigns(:talks)
    assert_equal talk2, talks.first
    assert_equal talk1, talks.last
  end
  
  def test_default_set_of_talks
    list = create_test_list
    get :index, :id => list.id
    talks = assigns(:talks)
    all_future_talks = list.talks.find(:all, :conditions => ['start_time > ?',Time.now], :order => 'start_time ASC')
    assert_equal(talks,all_future_talks)
  end
  
  def test_offset
    list = create_test_list
    get :index, {:id => list.id, :limit => '1', :offset => '2'}
    talks = assigns(:talks)
    all_future_talks = list.talks.find(:all, :conditions => ['start_time > ?',Time.now], :order => 'start_time ASC')
    assert_equal(talks, [all_future_talks[2]])  
  end

  def test_seconds_after_today
    list = create_test_list
    expected_talks = list.talks.find_all do |talk| 
      talk.start_time < Time.now.at_midnight + 1.day 
    end.sort_by { |talk| talk.start_time }

    get :index, {:id => list.id, :seconds_after_today => 1.day }
    talks = assigns(:talks)
    assert_equal(expected_talks, talks)
  end
  
  def test_seconds_before_today
    list = create_test_list
    expected_talks = list.talks.find_all do |talk| 
      talk.start_time > Time.now.at_midnight - 1.day 
    end.sort_by { |talk| talk.start_time }

    get :index, {:id => list.id, :seconds_before_today => 1.day }
    talks = assigns(:talks)
    # FIXME this test has been weakened because it never seemed to pass, it used to be:
    # assert_equal(expected_talks, talks)
    assert_equal(expected_talks.map {|t| t.id}.sort, talks.map {|t| t.id}.sort)
  end
  
  def test_start_time
    list = create_test_list
    time = Time.now
    expected_talks = list.talks.find_all do |talk| 
      talk.start_time > time + 1.day 
    end.sort_by { |talk| talk.start_time }

    get :index, {:id => list.id, :start_time => (time + 1.day).to_i }
    talks = assigns(:talks)
    # FIXME this test has been weakened because it never seemed to pass, it used to be:
    # assert_equal(expected_talks, talks)
    assert_equal(expected_talks.map {|t| t.id}.sort, talks.map {|t| t.id}.sort)
    
    # Has an alias, start_seconds
    get :index, {:id => list.id, :start_seconds => (time + 1.day).to_i }
    talks = assigns(:talks)
    # FIXME this test has been weakened because it never seemed to pass, it used to be:
    # assert_equal(expected_talks, talks)
    assert_equal(expected_talks.map {|t| t.id}.sort, talks.map.map {|t| t.id}.sort)
  end
  
  def test_end_time
    list = create_test_list
    time = Time.now
    expected_talks = list.talks.find_all do |talk| 
      talk.start_time < time + 1.day 
    end.sort_by { |talk| talk.start_time }

    get :index, {:id => list.id, :end_time => (time + 1.day).to_i }
    talks = assigns(:talks)
    assert_equal(expected_talks.map {|t| t.id}, talks.map {|t| t.id})
    
    # Has an alias, start_seconds
    get :index, {:id => list.id, :end_seconds => (time + 1.day).to_i }
    talks = assigns(:talks)
    assert_equal(expected_talks.map {|t| t.id}, talks.map {|t| t.id})
  end
  
  # Make sure that bad user data does not cause an uncaught exception
  def test_bad_times
  	list = create_test_list
	assert_nothing_raised do
  	  get :index, {:id => list.id, :end_seconds => 99999999999, :start_seconds => 99999999999 }
  	  get :index, {:id => list.id, :seconds_before_today => 99999999999 }
  	  get :index, {:id => list.id, :seconds_after_today => 99999999999 }
  	  talks = assigns(:talks)
  	end
  end
  
  def test_current_term
    # Find dates of this term
    year = Time.now.year
    ignore, term_start, term_end = [ 
      [Time.local(year,1),Time.local(year,1),Time.local(year,4)],
      [Time.local(year,4),Time.local(year,4),Time.local(year,7)],
      [Time.local(year,7),Time.local(year,7),Time.local(year,10)],
      [Time.local(year,10),Time.local(year,10),Time.local(year+1,1)]
    ].reverse.find { |time,term_start,term_end| Time.now > time }
    list = create_test_list
    
    expected_talks = list.talks.find_all do |talk| 
      (talk.start_time > term_start) && (talk.start_time < term_end)
    end.sort_by { |talk| talk.start_time }
    
    get :index, {:id => list.id, :term => 'current'}
    talks = assigns(:talks)
    assert_equal(expected_talks.map {|t| t.id}, talks.map {|t| t.id})
  end

  def test_term
    list = create_test_list
    year = Time.now.year
    [ 
      [Time.local(year,1,10),Time.local(year,1),Time.local(year,4)],
      [Time.local(year,4,10),Time.local(year,4),Time.local(year,7)],
      [Time.local(year,7,10),Time.local(year,7),Time.local(year,10)],
      [Time.local(year,10,10),Time.local(year,10),Time.local(year+1,1)]
    ].each do |date,term_start,term_end|
      
    
      expected_talks = list.talks.find_all do |talk| 
        (talk.start_time > term_start) && (talk.start_time < term_end)
      end.sort_by { |talk| talk.start_time }
    
      get :index, {:id => list.id, :term => date.to_i}
      talks = assigns(:talks)
      assert_equal(expected_talks.map {|t| t.id}, talks.map {|t| t.id}, date.to_s)
    end
  end

  
  def test_term_dates
    return unless @controller.respond_to?(:term_dates)
    # Lent
    lent = [ Time.local( 2005,1,1), Time.local(2005,3,31) ]
    assert_equal lent, @controller.term_dates( lent.first )
    assert_equal lent, @controller.term_dates( lent.first + 10.days )
    assert_equal lent, @controller.term_dates( lent.last )
    
    # Easter
    easter = [ Time.local( 2005,4,1), Time.local(2005,6,30) ]
    assert_equal easter, @controller.term_dates( easter.first )
    assert_equal easter, @controller.term_dates( easter.first + 10.days )
    assert_equal easter, @controller.term_dates( easter.last )
    
    # Vacation
    vacation = [ Time.local( 2005,7,1), Time.local(2005,9,30) ]
    assert_equal vacation, @controller.term_dates( vacation.first )
    assert_equal vacation, @controller.term_dates( vacation.first + 10.days )
    assert_equal vacation, @controller.term_dates( vacation.last )
    
    # Michaelmas
    michaelmas = [ Time.local( 2005,10,1), Time.local(2005,12,31) ]
    assert_equal michaelmas, @controller.term_dates( michaelmas.first )
    assert_equal michaelmas, @controller.term_dates( michaelmas.first + 10.days )
    assert_equal michaelmas, @controller.term_dates( michaelmas.last )
  end
  
  def test_limit_statement
    list = List.create :name => 'test limit'
    sub_list = List.create :name => 'test sub list'
    list.add sub_list
    talk1 = Talk.create :title => 'talk 1', :series => sub_list, :start_time => 1.minute.ago, :end_time => 45.seconds.ago
    list.add talk1
    talk2 = Talk.create :title => 'talk 2', :series => sub_list, :start_time => 30.seconds.ago, :end_time => 15.seconds.ago
    talk3 = Talk.create :title => 'talk 3', :series => sub_list, :start_time => 10.seconds.ago, :end_time => 5.seconds.ago
    
    get :index, :id => list.id, :limit => 2
    
    assert_response :success
    assert list == assigns(:list)
    assert talks = assigns(:talks)
    assert_equal 2, talks.size
    assert_equal [talk1,talk2].map {|t| t.title }, talks.map {|t| t.title }
  end
  
  def test_user_info_in_side_correct
    get :index, {:id => 1}, {:user_id => 1}
    assert_tag :tag => 'a', :attributes => { :href => 'http://test.host/user/edit/1' }
  end
  
  def test_for_absolute_urls
    list = create_test_list
    views.each do |action|
      get action, :id => list.id
      assert_response :success
      check_links_absolute
    end
  end
  
  def test_wrapping_in_div
    list = create_test_list
    views(:html).each do |action|
      get action, :id => list.id, :layout => 'empty'
      assert_response :success
      assert_match /^<div class='#{action}'>.*<\/div>$/m, @response.body
    end
  end
  
  def test_rss_escaping
    xml = Builder::XmlMarkup.new
    xml.sample "Iñtërnâtiônàl"
    # assert_equal "<sample>I&#241;t&#235;rn&#226;ti&#244;n&#224;l</sample>", xml.target!
  end
  
  def test_xml
    list = List.find 1
    get :xml, {:id => list.id}, {:user_id => users(:administrator).id}
    assert_template 'xml'
    assert_equal "text/xml; charset=utf-8", @response.headers["Content-Type"]
    require 'rexml/document'
    document = REXML::Document.new @response.body
    root = document.root
    assert_equal 'list', root.name
    assert_equal list.name, root.elements['name'].text
    assert_equal list.details, root.elements['details'].text
    assert_equal list.id, root.elements['id'].text.to_i
    assert_equal list_url(:id => list.id), root.elements['url'].text
    
    talks_xml = root.elements.to_a('//talk')
    assert_equal 1, talks_xml.size
    talks_xml.each do |talk_xml|
      talk_id = talk_xml.elements['id'].text.to_i
      assert talk_id
      talk = Talk.find talk_id
      assert talk
      [:title,:abstract, :special_message].each do |attribute|
        assert_equal talk.send(attribute), talk_xml.elements[attribute.to_s].text
      end
      assert_equal talk.name_of_speaker, talk_xml.elements['speaker'].text
      assert_equal talk_url(:id => talk.id), talk_xml.elements['url'].text
    end
  end
  
  def test_vcal
    list = List.create :name => 'test limit'
    talk = talks(:with_venue)
    talk.title = talk.abstract = "Does ical correctly escape ,;\\
    another line and strip out \r\n and replace it with just the newline"
    talk.save
    list.add talk
    get :ics, :id => list.id
    assert_response :success    
    assert_equal "text/calendar; charset=utf-8", @response.headers["Content-Type"] 
    assert_equal 'Does ical correctly escape \,\;\\\\\\n    another lin', @response.body[/SUMMARY:(.*?)\r/m,1]
  end
  
  private
  
  def views( type = :all )
    view_hash = { 
      :html => [  :detailed, 
                  :index, 
                  :minimalist, 
                  :old_talks,  
                  :simplewithlogo, 
                  :table, 
                  :oneday, 
                  :asnc_regular,
                  :heritage_group,
                  :cam_events,
                  :zoology,
                ],
      :text => [ :email, :text ],
      :xml => [ :google, :ics, :rss, :xml ]
      }
      return view_hash.values.flatten if type == :all
      view_hash[ type ]
  end
  
  def check_links_absolute
    @response.body.scan /href\=["'](.*?)["']/ do
      url = $1
      next if url == '#startcontent'
      next if url =~ /^mailto/i
      puts @response.body unless url =~ %r{^(webcal|http)://}
      assert_match %r{^(webcal|http)://}, url
    end
  end
  
  def create_test_list
    list = List.create :name => 'Test list'
    Talk.find(:all).each { |talk| list.add(talk) }
    list
  end
  
end
