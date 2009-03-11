require File.dirname(__FILE__) + '/../test_helper'
require 'custom_view_controller'

# Re-raise errors caught by the controller.
class CustomViewController; def rescue_action(e) raise e end; end

class CustomViewControllerTest < Test::Unit::TestCase

  fixtures :lists, :custom_views

  def setup
    @controller = CustomViewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_doesnt_fail_when_search_engine_tries_bizare_request
    get :update
    assert_response 404
  end

  def test_legacy
    get :old_embed_feed, :id => 13
    assert_redirected_to list_url(:action => 'old_talks', :showvenues => 1, :showimg => 1, :showseries => 1, :layout => 'embed')

    get :old_show_listing, :id => 24
    assert_redirected_to list_url(:id => 5588, :action => 'index')

    get :old_show_series, :id => 22
    assert_redirected_to list_url(:id => 5354, :action => 'index')

  end

end
