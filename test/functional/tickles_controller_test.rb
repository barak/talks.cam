require File.dirname(__FILE__) + '/../test_helper'
require 'tickles_controller'

# Re-raise errors caught by the controller.
class TicklesController; def rescue_action(e) raise e end; end

class TicklesControllerTest < Test::Unit::TestCase
  fixtures :tickles, :lists

  def setup
    @controller = TicklesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_create_tickle_immediately_if_user_logged_in
    old_count = Tickle.count
    sender = User.create! :email => 'test2@talks.cam.ac.uk', :name => 'Mr Tickle'
    recipient = 'test@talks.cam.ac.uk'
    Mailer.deliveries.clear
    post :create, {:tickle => { :about_type => "List", :about_id => '1', :recipient_email => recipient }}, {:user_id => sender.id}
    assert_equal old_count+1, Tickle.count
    tickle = assigns(:tickle)
    assert_equal(lists(:one),tickle.about)
    assert_equal(recipient, tickle.recipient_email)
    assert_equal(sender, tickle.sender)
    assert_equal(sender.email, tickle.sender_email)
    assert_equal(sender.name, tickle.sender_name)
    assert Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == recipient ) }
    assert_redirected_to list_url(:id => lists(:one).id)
  end
  
  def should_present_new_page_if_user_not_logged_in
    old_count = Tickle.count
    sender = User.create! :email => 'test2@talks.cam.ac.uk', :name => 'Mr Tickle'
    recipient = 'test@talks.cam.ac.uk'
    Mailer.deliveries.clear
    post :create, {:tickle => { :about_type => "List", :about_id => '1', :recipient_email => recipient }}
    assert_response :success
    assert_template 'tickles/new'
  end


end
