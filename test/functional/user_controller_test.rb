require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  fixtures :users, :talks, :lists, :list_talks, :list_lists, :list_users
  
  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'user/new'
    post :create, :user => { :email => 'bob2@talks.cam', :send_email => true }
    user = User.find_by_email 'bob2@talks.cam'
    assert_not_nil user
    assert Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == user.email) }
    user = User.create! :name => 'bill', :email => 'webmaster2@talks.cam.ac.uk'
    assert_response :redirect
    follow_redirect
    assert_response :success
    assert_template "user/password_sent"
    post :create, :user => { :email => 'bob2@talks.cam' }
    user = assigns(:user)
    assert user.errors.on(:email)
    assert_response :success
    assert_template "user/new"
  end
  
  def test_edit
    user = users(:vic)
    get :edit, {:id => user.id}, {:user_id => user.id}
    assert_response :success
    assert_template 'user/edit'
    assert_select "p#ask_for_more_information", false
  end
  
  def test_edit_with_return_url
    user = users(:vic)
    get :edit, {:id => user.id}, {:user_id => user.id, "return_to" => 'somewhere'}
    assert_response :success
    assert_template 'user/edit'
    assert_select "p#ask_for_more_information", true
  end
  
  def test_show_with_return_url
    user = users(:vic)
    get :show, {:id => user.id}, {:user_id => user.id, "return_to" => 'somewhere'}
    assert_response :success
    assert_template 'user/show'
    assert_select "p#redirect_to_original_destination", true
  end
  
  def test_update
    user = users(:vic)
    post :update, {:id => user.id, :user => { :id => user.id, :name => 'a new name', :affiliation => 'a new affiliation', :email => 'new@email' }}, {:user_id => user.id}
    assert_response :redirect
    assert_redirected_to user_url(:id => user.id)
    user.reload
    assert_equal 'a new name', user.name
    assert_equal 'a new affiliation', user.affiliation
    assert_equal 'new@email', user.email
  end
  
  def test_update_password
    user = users(:vic)
    post :update, {:id => user.id, :user => { :id => user.id, :password => 'a new password' }}, {:user_id => user.id}
    user = assigns(:user)
    assert_equal false, user.valid?
    assert_response :success
    assert_template "user/change_password"
    
    post :update, {:id => user.id, :user => { :id => user.id, :existing_password => users(:vic).password, :password => 'a new password', :password_confirmation => 'a new password' } }, {:user_id => user.id}
    assert_response :redirect
    assert_redirected_to user_url(:id => user.id)
    user.reload
    assert_equal 'a new password', user.password
  end
end
