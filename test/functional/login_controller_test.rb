require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_password_request
    user = User.create! :email => 'lost.password@talks.cam.ac.uk'
    post :send_password, :email => user.email
    assert Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == user.email) && mail.subject == 'Your talks.cam password'}
  end
  
  def test_new_user_page
    user = User.create :email => 'bob2@talks.cam'
    post :not_raven_login, {:email => user.email,:password => user.password }
    assert_response :redirect
    assert_redirected_to user_url(:action => 'edit', :id => user.id)
  end
  
end
