require File.dirname(__FILE__) + '/../test_helper'
require 'list_controller'

# Re-raise errors caught by the controller.
class ListController; def rescue_action(e) raise e end; end

class ListControllerTest < Test::Unit::TestCase
  
  fixtures :lists, :users, :list_users
  
  def setup
    @controller = ListController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_must_be_logged_in_for_new
    get :new
    assert_redirect_to_login
  end
    
  def test_new_list
    get_as_user :vic, :new
    assert_response :success
    assert_tag 'form', :attributes => {:action => '/list/create', :enctype => "multipart/form-data", :method => 'post', :id => 'editlist' }
    assert_tag 'input', :attributes => {:name => 'list[name]', :id => 'list_name' }
    assert_tag 'textarea', :attributes => {:name => 'list[details]', :id => 'list_details'}, :content => ''
  end
  
  def test_must_be_logged_in_for_create
    put :create, {:list => {:name => 'new list', :details => 'new list details', :ex_directory => 1, :image => uploaded_gif(gif_image)}}
    assert_redirect_to_login
  end

  def test_choose
    get_as_user :vic, :choose
    assert_response :success
    # TODO is there anymore I can test?
  end
  
  def test_create
    post_as_user :vic, :create, {:list => {:name => 'new list', :details => 'new list details', :ex_directory => 1, :image => uploaded_gif(gif_image)}}
    assert list = List.find_by_name('new list')
    assert_equal 'new list', list.name
    assert_equal 'new list details', list.details
    assert_equal true, list.ex_directory?
    assert_equal [users(:vic)], list.users
    assert_equal true, list.image_id?

    assert_redirected_to list_url(:id => list.id)
  end

  def test_create_and_return
    post_as_user :vic, :create, {:list => {:name => 'new list'}, :return_to => "http://slashdot.org"}
    assert_redirected_to "http://slashdot.org"
  end
  
  def test_must_be_logged_in_for_edit
    get :edit, {:id => lists(:series).id}
    assert_redirect_to_login
  end
  
  def test_must_be_a_manager_to_edit
    get_as_user :vic, :edit, {:id => lists(:series).id}
    assert_permission_denied
  end
  
  def test_edit
    get_as_user :seriesowner, :edit, {:id => lists(:series).id}
    assert_equal lists(:series), assigns(:list)
    assert_response :success
  end
  
  def test_must_be_logged_in_for_edit_details
    get :edit_details, {:id => lists(:series).id}
    assert_redirect_to_login
  end
  
  def test_must_be_a_manager_to_edit_details
    get_as_user :vic, :edit_details, {:id => lists(:series).id}
    assert_permission_denied
  end
  
  def test_edit_details
    get_as_user :seriesowner, :edit_details, {:id => lists(:series).id}
    assert_equal lists(:series), list = assigns(:list)
    assert_response :success

    assert_tag 'form', :attributes => {:action => "/list/update/#{list.id}", :enctype => "multipart/form-data", :method => 'post', :id => 'editlist' }
    assert_tag 'input', :attributes => {:name => 'list[name]', :id => 'list_name', :value => list.name }
    assert_tag 'input', :attributes => {:name => 'list[image]', :id => 'list_image' }
    assert_tag 'textarea', :attributes => {:name => 'list[details]', :id => 'list_details'}, :content => list.details
  end

  def test_must_be_logged_in_for_update
    post :update, {:id => lists(:series).id, :list => {:name => 'test list r2', :details => 'test details r2', :ex_directory => 1, :image => uploaded_gif(gif_image) } }
    assert_redirect_to_login
  end
  
  def test_must_be_a_manager_to_update
    post_as_user :vic, :update, {:id => lists(:series).id, :list => {:name => 'test list r2', :details => 'test details r2', :ex_directory => 1, :image => uploaded_gif(gif_image) } }
    assert_permission_denied
  end
  
  def test_update
    post_as_user :seriesowner, :update, {:id => lists(:series).id, :list => {:name => 'test list r2', :details => 'test details r2', :ex_directory => 1, :image => uploaded_gif(gif_image) } }
    
    assert_response :redirect
    assert_redirected_to list_details_url(:action => "edit", :id => lists(:series).id )

    list = lists(:series).reload
    
    assert_equal 'test list r2', list.name
    assert_equal 'test details r2', list.details
    assert_equal true, list.ex_directory?
    assert_equal true, list.image_id?
  end
  
  def test_dont_replace_existing_image
      post_as_user :vic, :create, {:list => {:name => 'new list with image', :details => 'new list details', :ex_directory => 1, :image => uploaded_gif(gif_image)}}
      list = List.find_by_name 'new list with image'
      existing_image = list.image
      assert_kind_of(Image, existing_image)
      post_as_user :vic, :update, {:id => list.id, :list => {:name => 'new list with image - updated', :details => 'new list details', :ex_directory => 1, :image => ''}}
      list.reload
      assert_equal('new list with image - updated', list.name)
      assert_equal(existing_image, list.image)
  end
  
  def test_html_header
    list = List.create :name => 'test list', :details => 'test details'
    get :index, :id => list.id
    assert_match @response.headers['Content-Type'], 'text/html; charset=utf-8'
    assert_tag 'meta', :attributes => { 'http-equiv' =>"content-type", :content => "text-html; charset=utf-8"}
  end

  def test_index_as_user
    get_as_user :vic, :index, {:id => lists(:series).id}
    assert_response :success
  end
  
  def test_must_be_logged_in_for_destroy
    post :destroy, {:id => lists(:series).id}
    assert_redirect_to_login
  end
  
  def test_must_be_a_manager_to_update
    post_as_user :vic, :destroy, {:id => lists(:series).id}
    assert_permission_denied
  end
  
  def test_destroy
    post_as_user :seriesowner, :destroy, {:id => lists(:series).id}
    list = lists(:series).reload
    assert list.ex_directory?
    assert list.users.empty?
    assert list.parents.empty?
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
