require File.dirname(__FILE__) + '/../test_helper'
require 'talk_controller'

# Re-raise errors caught by the controller.
class TalkController; def rescue_action(e) raise e end; end

class TalkControllerTest < Test::Unit::TestCase
  
  fixtures :users, :talks, :lists, :list_talks, :list_lists, :list_users
  
  # Basic setup
   
  def setup
    @controller = TalkController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def talk
    talks(:one)
  end
  
  def series
    talk.series
  end
  
  def manager
    talk.series.managers.first
  end
  
  def not_a_manager
    users(:vic)
  end
  
  def new_attributes( existing_talk = true, new_talk_attributes = {} )
     {  :id => existing_talk ? talk.id : nil,
        :list_id => series.id,
        :talk => {
          :series_id => series.id,
          :title => 'The new talk title',
          :abstract => 'The talk abstract',
          :special_message => 'A very special message',
          :organiser_email => manager.email,
          :speaker_email => 'tamc2@cam.ac.uk',
          :name_of_speaker => '',
          :ex_directory => '1',
          :date_string => '2006/05/01',
          :start_time_string => '09:00',
          :end_time_string => '10:59',
          :venue_name => 'Venue three',
          :image => uploaded_gif(gif_image)
        }.merge(new_talk_attributes)
      }
  end
  
  # The simple view tests  
    
  def test_index
    get :index, :id => talk.id
    assert_response :success
    assert_template 'index'
    check_assigns_correctly talk
  end

  def test_index_as_user
    get :index, {:id => talk.id}, { :user_id => not_a_manager.id }
    assert_response :success
    assert_template 'index'
    check_assigns_correctly talk
  end
  
  def test_vcal
    talk.title = talk.abstract = "Does ical correctly escape ,;\\
    another line and strip out \r\n and replace it with just the newline"
    talk.save
    get :vcal, :id => talk.id
    assert_response :success    
    assert_equal "text/calendar; charset=utf-8", @response.headers["Content-Type"] 
    check_assigns_correctly talk
    assert_equal "text/calendar; charset=utf-8", @response.headers["Content-Type"] 
    assert_equal 'Does ical correctly escape \,\;\\\\\\n    another lin', @response.body[/SUMMARY:(.*?)\r/m,1]
    assert_equal 'Does ical correctly escape \,\;\\\\\\n    another lin', @response.body[/DESCRIPTION:(.*?)\r/m,1]
  end
  
  def test_404_when_not_found
    assert_raise(ActiveRecord::RecordNotFound) { get :index, :id => 9090909090 }
    assert_raise(ActiveRecord::RecordNotFound) { get :index }
  end
  
  def test_404_when_not_found
    assert_raise(ActiveRecord::RecordNotFound) { get :vcal, :id => 9090909090 }
    assert_raise(ActiveRecord::RecordNotFound) { get :vcal }
  end
  
  def test_must_be_logged_in
    get :edit, {:list_id => series.id}
    assert_response :redirect
    assert_redirected_to login_url
    post :update, new_attributes
    assert_redirected_to login_url
  end

  def test_can_use_http_authentication_instead_of_logging_in
    @request.env['HTTP_AUTHORIZATION'] = "Basic " + Base64.encode64("#{manager.email}:#{manager.password}")
    get :edit, {:list_id => series.id}
    assert_response :success
    @request.env.delete('HTTP_AUTHORIZATION')
  end
  
  def test_api
    xhr :post, :update, {:format => 'xml', :talk => {:title => 'new talk created using the api',:series_id => series.id}}, {:user_id => manager.id}
    assert Talk.find_by_title('new talk created using the api')
    assert_match 'application/xml', @response.headers['Content-Type']
    assert_response :success
  end
  
  def test_create_security
    get :new, {:list_id => series.id}
    assert_response :redirect
    get :new, {:list_id => series.id}, {:user_id => not_a_manager.id}
    assert_response 401
    post :create, new_attributes(false), {:user_id => not_a_manager.id}
    assert_response 401
  end
  
  def test_new
    get :new, {:list_id => series.id}, {:user_id => manager.id}
    assert_response :success
    new_talk = assigns :talk
    assert_equal true, new_talk.ex_directory?
    assert_equal new_talk.series, series
    assert_template 'edit'
  end
  
  def test_create
     post :create, new_attributes(false), {:user_id => manager.id}
     assert_response :redirect
     talk = Talk.find_by_title new_attributes[:talk][:title]
     assert_equal new_attributes[:talk][:title], talk.title
     assert_equal new_attributes[:talk][:abstract], talk.abstract
     assert_equal new_attributes[:talk][:special_message], talk.special_message
     assert_equal Time.local(2006,05,01,9,0), talk.start_time
     assert_equal Time.local(2006,05,01,10,59), talk.end_time
     assert_kind_of Venue, talk.venue
     assert_equal lists(:venue3), talk.venue
     assert_equal true, talk.image_id?    
  end
  
  def test_cannot_edit_talk_when_not_a_manager
    get :edit, {:id => talk.id}, {:user_id => not_a_manager.id}
    assert_response 401
  end
  
  def test_edit
    get :edit, {:id => talk.id}, {:user_id => manager.id}
    assert_response :success 
    assert_equal talk, assigns(:talk)
  end
  
  def test_cannot_save_talk_when_not_a_manager
    post :update, new_attributes, {:user_id => not_a_manager.id}
    assert_response 401    
  end
  
  def test_save_existing_talk
    assert_equal false, talk.ex_directory?
    post :update, new_attributes, {:user_id => manager.id}  
    assert_response :redirect
    assert_redirected_to talk_url(:id => talk.id)
    
    talk.reload
    assert_equal new_attributes[:talk][:title], talk.title
    assert_equal new_attributes[:talk][:abstract], talk.abstract
    assert_equal new_attributes[:talk][:special_message], talk.special_message
    assert_equal true, talk.ex_directory?
    assert_equal Time.local(2006,05,01,9,0), talk.start_time
    assert_equal Time.local(2006,05,01,10,59), talk.end_time
    assert_kind_of Venue, talk.venue
    assert_equal lists(:venue3), talk.venue
    assert_equal true, talk.image_id?
  end
  
  def test_dont_create_unneccessary_images
    attributes = new_attributes(false)
    attributes[:talk][:image] = ''
    post :update, attributes, {:user_id => manager.id}
    
    attributes = new_attributes(true)
    attributes[:talk][:image] = ''
    post :update, attributes, {:user_id => manager.id}
  end
  
  def test_save_with_new_venue
    post :update, new_attributes(false, :venue_name => 'A venue never seen before'), {:user_id => manager.id}
    assert_equal 'A venue never seen before', assigns(:talk).venue.name
  end
  
  def test_help_methods
    [ 'talk_title','talk_abstract','talk_date_string','talk_ex_directory','talk_image',
      'talk_special_message','talk_name_of_speaker','talk_send_speaker_email','undefined',
      'talk_venue_name','talk_start_time_string',
      'talk_end_time_string','talk_organiser_email'].each do |field|
      get :help, {:field => field, :list_id => series.id}, {:user_id => manager.id}
      assert_response :success
      assert_equal series, assigns(:list)
      assert_kind_of UsualDetails, assigns(:usual_details)
      assert_template "_help_#{field}" 
    end
  end
  
  def check_assigns_correctly( talk )
    assert_equal talk, assigns(:talk)
    # assert_equal talk.series, assigns(:list)
  end
  
  # Test deletion
  def test_cannot_delete_talk_unless_manager
    get :delete, {:id => talk.id}, {:user_id => not_a_manager.id}
    assert_response 401
  end
  
  def test_delete_talk
    get :delete, {:id => talk.id}, {:user_id => manager.id}
    assert_response :success
    assert_template "delete"
    talk.reload
    assert_equal false, talk.ex_directory?
    
    post :delete, {:id => talk.id}, {:user_id => manager.id}
    
    assert_response :redirect
    assert_redirected_to list_url(:id => series.id)
    
    talk.reload
    assert_equal true, talk.ex_directory?
  end
  
  # Test sending an email to the speaker
  def test_dont_send_email_to_the_speaker
    Mailer.deliveries.clear
    post :update, new_attributes(false, :send_speaker_email => ''), {:user_id => manager.id}
      mail = Mailer.deliveries.find { |mail| mail.to[0] == 'tamc2@cam.ac.uk' && mail.subject == 'Giving a talk in Cambridge' }
      assert !mail
      mail = Mailer.deliveries.find { |mail| mail.to[0] == 'tamc2@cam.ac.uk' && mail.subject == 'Your talks.cam password' }
      assert !mail
  end
  
  def test_do_send_email_to_the_speaker
    Mailer.deliveries.clear
    post :update, new_attributes(false, :send_speaker_email => '1'), {:user_id => manager.id}
      mail = Mailer.deliveries.find { |mail| mail.to[0] == 'tamc2@cam.ac.uk' && mail.subject == 'Giving a talk in Cambridge' }
      assert mail
      assert_equal mail.cc[0], manager.email
      mail = Mailer.deliveries.find { |mail| mail.to[0] == 'tamc2@cam.ac.uk' && mail.subject == 'Your talks.cam password' }
      assert mail
  end
  
end
