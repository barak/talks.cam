require File.dirname(__FILE__) + '/../test_helper'
require 'document_controller'

# Re-raise errors caught by the controller.
class DocumentController; def rescue_action(e) raise e end; end

class DocumentControllerTest < Test::Unit::TestCase
  fixtures :documents
  
  def setup
    @controller = DocumentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_routing
    with_options :controller => 'document', :action => 'show' do |r|
      r.assert_routing "/document/this+is+a+good+idea", :name => 'this is a good idea'
      r.assert_routing "/document/this+is+a+good+idea+for+talks.cam", :name => 'this is a good idea for talks.cam'
    end
  end
  
  def test_index_sorts_alphabetically
    get :index
    assert_response :success
    
    index = assigns(:documents)
    assert_kind_of Array, index
    assert_equal 2, index.size
    assert_equal documents(:first), index.first
    assert_equal documents(:second), index.last
  end
  
end
