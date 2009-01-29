require File.dirname(__FILE__) + '/../test_helper'
require 'reminder_controller'

# Re-raise errors caught by the controller.
class ReminderController; def rescue_action(e) raise e end; end

class ReminderControllerTest < Test::Unit::TestCase
  
  fixtures :users, :lists, :email_subscriptions
  
  def setup
    @controller = ReminderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def list
    lists(:one)
  end

  def user
    users(:vic)
  end
  
  def not_vic
    users(:jim)
  end
  
  def administrator
    users(:administrator)
  end
  
  def subscription
    EmailSubscription.create :user => user, :list => list
  end

  def test_must_be_a_user
    get :index
    assert_response :redirect
    assert_redirected_to login_url
    get :create, { :list => list.id }
    assert_response :redirect
    assert_redirected_to login_url
    get :destory, { :list => list.id }
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def test_must_be_authorized
    get :destroy, { :id => subscription.id }, {:user_id => not_vic.id }
    assert_response 401
    get :destroy, { :id => subscription.id }, {:user_id => administrator.id }
    assert_response :redirect
  end
    
  def test_create
    assert_equal 1, user.email_subscriptions.size
    get :create, { :list => list.id }, {:user_id => user.id }
    assert_response :redirect
    assert_redirected_to reminder_url
    assert_equal 2, user.email_subscriptions.size
  end
  
  def test_destroy
    new_sub = subscription
    assert_equal 2, user.email_subscriptions.size
    get :destroy, { :id => new_sub.id }, {:user_id => user.id }
    assert_response :redirect
    assert_redirected_to reminder_url
    assert_equal 1, user.email_subscriptions.size
  end
  
  def test_index
    new_sub = subscription
    assert_equal 2, user.email_subscriptions.size
    get :index, {}, {:user_id => user.id }
    assert_response :success
    assert_equal user, assigns(:user)
    assert_equal user.email_subscriptions, assigns(:subscriptions)
  end
  
  
end
