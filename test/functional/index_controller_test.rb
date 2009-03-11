require File.dirname(__FILE__) + '/../test_helper'
require 'index_controller'

# Re-raise errors caught by the controller.
class IndexController; def rescue_action(e) raise e end; end

class IndexControllerTest < Test::Unit::TestCase
  fixtures :lists, :users
  
  def setup
    @controller = IndexController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_talks
    get :talks
    assert_response :success
    # TODO put talks fixtures in, and check results
  end

  def test_venues
    get :venues
    assert_response :success
    
    venues = assigns(:lists)
    assert_kind_of Array, venues
    assert_equal 3, venues.size
    venues.each do |venue|
      assert_kind_of Venue, venue
    end
  end
  
  def test_lists
    get :lists
    assert_response :success
    
    lists = assigns(:lists)
    assert_kind_of Array, lists
    assert_equal 8, lists.size
    lists.each do |list|
      assert_kind_of List, list
      assert_equal false, list.ex_directory?
      assert_equal false, list.is_a?(Venue)
    end
  end
  
  def test_users
    User.find(:all).each { |u| u.save! } # Make sure that they all have a name_for_index field updated correctly
    get :users, :letter => 'u'
    assert_response :success
    
    users = assigns(:users)
    assert_equal(2, users.size)
    assert_equal users(:jim),users.first
    assert_equal users(:vic),users.last
  end

  def test_dates
    get :dates
    time = assigns(:time)
    assert_equal Time.now.at_beginning_of_day, time
    get :dates, :year => 2005, :month => 3, :day => 12
    time = assigns(:time)
    assert_equal Time.local(2005,3,12), time
  end

  def test_new
    get :talks, :letter => 'new'
    assert_response :success
    get :venues, :letter => 'new'
    assert_response :success
    get :lists, :letter => 'new'
    assert_response :success
    get :users, :letter => 'new'
    assert_response :success
    get :dates, :letter => 'new'
    assert_response :success
    # TODO check results
  end

  def test_updated
    get :talks, :letter => 'updated'
    assert_response :success
    get :venues, :letter => 'updated'
    assert_response :success
    get :lists, :letter => 'updated'
    assert_response :success
    get :users, :letter => 'updated'
    assert_response :success
    get :dates, :letter => 'updated'
    assert_response :success
    # TODO check results
  end

end
