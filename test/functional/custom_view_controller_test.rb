require File.dirname(__FILE__) + '/../test_helper'
require 'custom_view_controller'

# Re-raise errors caught by the controller.
class CustomViewController; def rescue_action(e) raise e end; end

class CustomViewControllerTest < Test::Unit::TestCase
  def setup
    @controller = CustomViewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_doesnt_fail_when_search_engine_tries_bizare_request
    get :update
    assert_response 404
  end
end
