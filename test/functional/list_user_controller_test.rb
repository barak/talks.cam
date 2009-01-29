require File.dirname(__FILE__) + '/../test_helper'
require 'list_user_controller'

# Re-raise errors caught by the controller.
class ListUserController; def rescue_action(e) raise e end; end

class ListUserControllerTest < Test::Unit::TestCase
  fixtures :lists, :users, :list_users
  
  def setup
    @controller = ListUserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # def test_index_without_anything
  #   get :index
  #   assert_response :success
  #   assert assigns(:users)
  #   assert_equal 2, assigns(:users).size
  # end
  
  def test_index_with_list
    get :index, :list_id => lists(:series).id
    assert_response :success
    assert assigns(:users)
    assert assigns(:list)
    assert_equal [users(:seriesowner)], assigns(:users)
    assert_equal lists(:series), assigns(:list)
  end
  
  def test_must_be_logged_in_to_edit
    get :edit, :list_id => lists(:series).id
    assert_redirect_to_login
  end
  
  def test_must_be_list_owner_to_edit
    get_as_user :vic, :edit, :list_id => lists(:series).id
    assert_permission_denied
  end
  
  def test_edit
    get_as_user :seriesowner, :edit, :list_id => lists(:series).id
    assert_response :success
    assert assigns(:list_users)
    assert assigns(:list)
    assert_equal users(:seriesowner), assigns(:list_users).first.user
    assert_equal lists(:series), assigns(:list)    
  end
  
  def test_must_be_logged_in_to_create
    post :create, :list_user => { :list_id => lists(:series).id, :user_email => users(:vic).email }
    assert_redirect_to_login
  end
  
  def test_must_be_list_owner_to_create
    post_as_user :vic, :create, :list_user => { :list_id => lists(:series).id, :user_email => users(:vic).email }
  end
  
  def test_create_with_existing_user
    post_as_user :seriesowner, :create, :list_user => { :list_id => lists(:series).id, :user_email => users(:vic).email }
    assert assigns(:list)
    assert_equal lists(:series), assigns(:list)
    assert lists(:series).users.include?(users(:vic))
    assert_redirected_to list_user_url(:list_id => lists(:series).id, :action => 'edit')
  end
  
  def test_create_with_new_user
    post_as_user :seriesowner, :create, :list_user => { :list_id => lists(:series).id, :user_email => 'new-manager@talks.cam.ac.uk' }
    assert assigns(:list)
    assert_equal lists(:series), assigns(:list)
    assert new_manager = User.find_by_email('new-manager@talks.cam.ac.uk')
    assert lists(:series).users.include?(new_manager)
    assert_redirected_to list_user_url(:list_id => lists(:series).id, :action => 'edit')
  end

  def test_must_be_logged_in_to_destroy
    post :destroy, :list_user => { :list_id => lists(:series).id, :user_id => users(:vic).id }
    assert_redirect_to_login
  end
  
  def test_must_be_list_owner_to_destroy
    post_as_user :vic, :destroy, :list_user => { :list_id => lists(:series).id, :user_id => users(:vic).id }
  end
  
  def test_destroy
    post_as_user :seriesowner, :destroy, :id => list_users(:seriesowner).id
    assert assigns(:list)
    assert_equal lists(:series), assigns(:list)
    assert !lists(:series).users(true).include?(users(:seriesowner))
    assert_redirected_to list_user_url(:list_id => lists(:series).id, :action => 'edit')
  end
  
  private
  
  def post_as_user( user, action, parameters = {} )
    do_as_user :post, user, action, parameters
  end
  
  def get_as_user( user, action, parameters = {} )
    do_as_user :get, user, action, parameters
  end
  
  def do_as_user(request_type, user, action, parameters = {} )
    send( request_type, action, parameters, {:user_id => users(user).id } )
  end
  
  def assert_redirect_to_login
    assert_response :redirect
    assert_redirected_to login_url
  end
  
  def assert_permission_denied
    assert_response 401
  end
  
end
