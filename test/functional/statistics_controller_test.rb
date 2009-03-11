require File.dirname(__FILE__) + '/../test_helper'
require 'statistics_controller'

# Re-raise errors caught by the controller.
class StatisticsController; def rescue_action(e) raise e end; end

class StatisticsControllerTest < Test::Unit::TestCase
  fixtures :users, :talks, :lists
  
  def setup
    @controller = StatisticsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_fixtures_files
    get :index
    assert_equal 6,  assigns(:number_of_users)
    assert_equal 1,  assigns(:number_of_recent_users)
    assert_equal 20, assigns(:number_of_talks)
    assert_equal (Time.now.month+1),  assigns(:number_of_past_talks)
    assert_equal 20-(Time.now.month+1), assigns(:number_of_future_talks)
    assert_equal 6,  assigns(:number_of_user_favourites)
    assert_equal 3,  assigns(:number_of_venues)
    assert_equal 1,  assigns(:number_of_series)
    assert_equal 2,  assigns(:number_of_listings)
  end
end
